# Copyright (C) 2026 The q2q Device Tree Authors
# SPDX-License-Identifier: Apache-2.0

LOCAL_PATH := device/samsung/q2q

$(call inherit-product, device/samsung/sm8350-common/common.mk)

# The stock q2q layout uses dynamic logical partitions inside super.
PRODUCT_USE_DYNAMIC_PARTITIONS := true
PRODUCT_BUILD_PRODUCT_IMAGE := true
PRODUCT_BUILD_ODM_IMAGE := true
PRODUCT_OTA_ENFORCE_VINTF_KERNEL_REQUIREMENTS := false
# Samsung stock vendor_boot image must remain untouched to avoid ABL Download Mode loop (wb_reason=0xE03)
PRODUCT_BUILD_VENDOR_BOOT_IMAGE := false
PRODUCT_BUILD_VBMETA_IMAGE := true

# Set LCD density and SurfaceFlinger properties for Q2Q displays
PRODUCT_PROPERTY_OVERRIDES += \
    ro.sf.lcd_density=420

# Ensure ADB is enabled and accessible without key prompts during bringup
PRODUCT_SYSTEM_PROPERTIES += \
    persist.sys.usb.config=adb \
    persist.service.adb.enable=1 \
    persist.service.debuggable=1 \
    ro.adb.secure=0 \
    persist.sys.disable_rescue=true \
    ro.treble.enabled=true \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=3 \
    debug.renderengine.backend=skiaglthreaded \
    debug.sf.disable_backpressure=1 \
    debug.sf.latch_unsignaled=1 \
    ro.hardware.egl=adreno \
    ro.hardware.vulkan=adreno \
    ro.board.platform=lahaina \
    pm.dexopt.first-boot=verify \
    pm.dexopt.boot-after-ota=verify \
    pm.dexopt.boot-after-mainline-update=verify \
    dalvik.vm.usejit=true \
    dalvik.vm.usejitprofiles=false \
    ro.sys.fw.dex2oat_thread_count=4 \
    dalvik.vm.dex2oat-threads=4 \
    dalvik.vm.boot-dex2oat-threads=4 \
    ro.kernel.ebpf.supported=false \
    ro.net.bpf.supported=false \
    persist.sys.fflag.override.settings_enable_bpf=false \
    persist.sys.fuse=true \
    ro.sys.sdcardfs=false \
    persist.radio.multisim.config=dsds \
    ro.multisim.simslotcount=2

# Disable Qualcomm SPU / StrongBox SPU checks and set unencrypted data state
PRODUCT_VENDOR_PROPERTIES += \
    vendor.gatekeeper.disable_spu=true \
    vendor.disable_spu=1 \
    ro.crypto.state=unencrypted \
    ro.crypto.type=none \
    ro.security.vaultkeeper.native=0

PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/dtbo.img:dtbo.img \
    $(LOCAL_PATH)/configs/camera/camxoverridesettings.txt:system/etc/q2q_camera/camxoverridesettings.txt \
    $(LOCAL_PATH)/seccomp/samsung.software.media.c2@1.0-policy:system/etc/seccomp_policy/samsung.software.media.c2@1.0-policy \
    $(LOCAL_PATH)/init.q2q.system.rc:system/etc/init/init.q2q.system.rc \
    $(LOCAL_PATH)/init.q2q.override.rc:system/etc/init/init.q2q.override.rc \
    $(LOCAL_PATH)/init.q2q.usb.sh:system/bin/init.q2q.usb.sh \
    $(LOCAL_PATH)/init.q2q.modules.sh:system/bin/init.q2q.modules.sh \
    $(LOCAL_PATH)/init.q2q.vendor_rw.sh:system/bin/init.q2q.vendor_rw.sh \
    $(LOCAL_PATH)/sepolicy/30.0.cil:$(TARGET_COPY_OUT_SYSTEM)/etc/selinux/mapping/30.0.cil \
    $(LOCAL_PATH)/sepolicy/30.0.compat.cil:$(TARGET_COPY_OUT_SYSTEM)/etc/selinux/mapping/30.0.compat.cil \
    $(LOCAL_PATH)/cgroups.json:$(TARGET_COPY_OUT_VENDOR)/etc/cgroups.json \
    $(LOCAL_PATH)/cgroups.json:system/etc/cgroups.json \
    system/core/rootdir/etc/ld.config.txt:system/etc/ld.config.txt \
    $(foreach f,$(wildcard $(LOCAL_PATH)/vndk-30/lib64/*.so),$(f):system/lib64/vndk-30/$(notdir $(f))) \
    $(foreach f,$(wildcard $(LOCAL_PATH)/vndk-30/lib/*.so),$(f):system/lib/vndk-30/$(notdir $(f)))

# Extra VNDK versions for Android 15 vendor binary library compatibility
PRODUCT_EXTRA_VNDK_VERSIONS := 33 34

# Security, HIDL & AIDL compatibility shims & libraries for Android 15 vendor on Android 17 framework
PRODUCT_PACKAGES += \
    android.hardware.audio@6.0 \
    android.hardware.audio.common@6.0 \
    android.hardware.audio.effect@6.0 \
    android.hardware.boot-service.qti \
    android.hardware.camera.provider@2.4 \
    android.hardware.cas@1.0 \
    android.hardware.drm@1.0 \
    android.hardware.gatekeeper@1.0 \
    android.hardware.gnss@1.0 \
    android.hardware.graphics.allocator@2.0 \
    android.hardware.graphics.allocator@3.0 \
    android.hardware.graphics.allocator@4.0 \
    android.hardware.graphics.composer@2.4 \
    android.hardware.graphics.mapper@2.0 \
    android.hardware.graphics.mapper@3.0 \
    android.hardware.graphics.mapper@4.0 \
    android.hardware.health@2.1-impl \
    android.hardware.health@2.1-service \
    android.hardware.keymaster@4.0 \
    android.hardware.media.omx@1.0 \
    android.hardware.nfc@1.0 \
    android.hardware.radio@1.0 \
    android.hardware.secure_element@1.0 \
    android.hardware.sensors@2.0 \
    android.hardware.sensors@2.1 \
    android.hardware.thermal@2.0 \
    android.hardware.wifi@1.0 \
    android.hardware.wifi.hostapd@1.0 \
    android.hardware.wifi.supplicant@1.0 \
    android.hidl.allocator@1.0 \
    android.hidl.memory@1.0 \
    android.hidl.memory.block@1.0 \
    android.hidl.memory.token@1.0 \
    hwservicemanager \
    libbinder_ndk \
    libhidlbase \
    libhidltransport \
    libhwbinder \
    vndservicemanager

PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)

# Generated after proprietary blobs are extracted into vendor/samsung/q2q.
$(call inherit-product-if-exists, vendor/samsung/q2q/q2q-vendor.mk)

# Prevent recovery init script from leaking into system root ramdisk (placed at bottom to execute after common.mk inheritance)
PRODUCT_COPY_FILES := $(filter-out device/samsung/sm8350-common/recovery/root/init.recovery.qcom.rc:root/init.recovery.qcom.rc,$(PRODUCT_COPY_FILES))
