/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <dlfcn.h>
#include <pthread.h>
#include <stdint.h>
#include <unistd.h>
#include <string_view>

#include <android/log.h>

#define LOG_TAG "q2q_hidl_shim"

extern "C" {
void ABinderProcess_setThreadPoolMaxThreadCount(uint32_t numThreads);
void ABinderProcess_startThreadPool(void);
}

namespace android {
namespace hardware {
namespace details {
void check(bool cond, const char* msg) {
    if (!cond) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, "HIDL check failed: %s",
                            msg ? msg : "(null)");
    }
}
}  // namespace details
}  // namespace hardware

namespace base {
struct borrowed_fd {
    int fd_;
};

bool WriteStringToFd(std::string_view content, borrowed_fd fd) {
    const char* p = content.data();
    size_t left = content.size();
    while (left > 0) {
        ssize_t n = write(fd.fd_, p, left);
        if (n <= 0) {
            return false;
        }
        p += n;
        left -= static_cast<size_t>(n);
    }
    return true;
}
}  // namespace base
}  // namespace android

static int g_initialized = 0;

static void* register_bt_audio_aidl(void*) {
    void* handle = dlopen("/odm/lib/bt/android.hardware.bluetooth.audio-impl.so",
                          RTLD_NOW | RTLD_GLOBAL);
    if (!handle) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG,
                            "dlopen(android.hardware.bluetooth.audio-impl.so) failed: %s",
                            dlerror());
        return nullptr;
    }

    using CreateFn = int32_t (*)();
    auto fn = reinterpret_cast<CreateFn>(
        dlsym(handle, "createIBluetoothAudioProviderFactory"));
    if (!fn) {
        __android_log_print(ANDROID_LOG_ERROR, LOG_TAG,
                            "dlsym(createIBluetoothAudioProviderFactory) failed: %s",
                            dlerror());
        return nullptr;
    }

    int32_t status = fn();
    __android_log_print(ANDROID_LOG_INFO, LOG_TAG,
                        "createIBluetoothAudioProviderFactory() in audio.service returned %d",
                        status);
    return nullptr;
}

__attribute__((constructor)) static void init_binder_pool() {
    if (__atomic_exchange_n(&g_initialized, 1, __ATOMIC_SEQ_CST) != 0) {
        return;
    }

    ABinderProcess_setThreadPoolMaxThreadCount(4);
    ABinderProcess_startThreadPool();

    pthread_t tid;
    if (pthread_create(&tid, nullptr, register_bt_audio_aidl, nullptr) == 0) {
        pthread_detach(tid);
    }
}
