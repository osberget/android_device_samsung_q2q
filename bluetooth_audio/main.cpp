/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "q2q_bt_audio_service"

#include <android/binder_manager.h>
#include <android/binder_process.h>
#include <utils/Log.h>

extern "C" binder_status_t createIBluetoothAudioProviderFactory();

int main(int /* argc */, char** /* argv */) {
    ALOGI("Starting q2q Bluetooth Audio AIDL service...");
    ABinderProcess_setThreadPoolMaxThreadCount(4);
    ABinderProcess_startThreadPool();

    binder_status_t status = createIBluetoothAudioProviderFactory();
    if (status != STATUS_OK) {
        ALOGE("Failed to register Bluetooth Audio AIDL service: %d", status);
        return 1;
    }

    ALOGI("q2q Bluetooth Audio AIDL service registered successfully");
    ABinderProcess_joinThreadPool();
    return 0;
}
