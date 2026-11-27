/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#define LOG_TAG "q2q_powershare"

#include <aidl/vendor/lineage/powershare/BnPowerShare.h>
#include <android-base/file.h>
#include <android-base/logging.h>
#include <android-base/strings.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>

using ::android::base::ReadFileToString;
using ::android::base::Trim;
using ::android::base::WriteStringToFile;

namespace {

constexpr const char* kPowerSharePath = "/sys/class/power_supply/battery/wc_tx_en";
constexpr const char* kPowerShareStopCapacityPath =
        "/sys/class/power_supply/battery/wc_tx_stop_capacity";
constexpr const char* kPowerShareEnabled = "1";
constexpr const char* kPowerShareDisabled = "0";

class PowerShare : public ::aidl::vendor::lineage::powershare::BnPowerShare {
  public:
    ndk::ScopedAStatus getMinBattery(int32_t* _aidl_return) override {
        std::string value;
        if (!ReadFileToString(kPowerShareStopCapacityPath, &value)) {
            LOG(ERROR) << "Failed to get PowerShare minimum battery level";
            return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
        }
        *_aidl_return = std::stoi(value);
        return ndk::ScopedAStatus::ok();
    }

    ndk::ScopedAStatus isEnabled(bool* _aidl_return) override {
        std::string value;
        if (!ReadFileToString(kPowerSharePath, &value)) {
            LOG(ERROR) << "Failed to read current PowerShare state";
            return ndk::ScopedAStatus::fromExceptionCode(EX_UNSUPPORTED_OPERATION);
        }
        *_aidl_return = (Trim(value) == kPowerShareEnabled);
        return ndk::ScopedAStatus::ok();
    }

    ndk::ScopedAStatus setEnabled(bool enable) override {
        std::string value = enable ? kPowerShareEnabled : kPowerShareDisabled;
        if (!WriteStringToFile(value, kPowerSharePath)) {
            LOG(ERROR) << "Failed to write PowerShare state";
            return ndk::ScopedAStatus::fromExceptionCode(EX_SERVICE_SPECIFIC);
        }
        return ndk::ScopedAStatus::ok();
    }

    ndk::ScopedAStatus setMinBattery(int32_t minBattery) override {
        if (!WriteStringToFile(std::to_string(minBattery), kPowerShareStopCapacityPath)) {
            LOG(ERROR) << "Failed to set PowerShare minimum battery level";
            return ndk::ScopedAStatus::fromExceptionCode(EX_SERVICE_SPECIFIC);
        }
        return ndk::ScopedAStatus::ok();
    }
};

}  // namespace

int main() {
    ABinderProcess_setThreadPoolMaxThreadCount(0);
    std::shared_ptr<PowerShare> powershare = ndk::SharedRefBase::make<PowerShare>();
    const std::string instance = std::string(PowerShare::descriptor) + "/default";
    binder_status_t status =
            AServiceManager_addService(powershare->asBinder().get(), instance.c_str());
    CHECK_EQ(status, STATUS_OK);
    ABinderProcess_joinThreadPool();
    return EXIT_FAILURE;
}
