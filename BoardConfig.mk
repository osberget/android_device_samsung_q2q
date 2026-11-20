# Copyright (C) 2026 The q2q Device Tree Authors
# SPDX-License-Identifier: Apache-2.0

DEVICE_PATH := device/samsung/q2q

include device/samsung/sm8350-common/BoardConfigCommon.mk

# Disable full recovery image in boot.img so device performs normal system boot
BOARD_USES_FULL_RECOVERY_IMAGE := false

# Device / platform identity confirmed from Samsung's q2q kernel source and
# the SM-F926B stock vendor_boot image.
BOARD_VENDOR := samsung
TARGET_BOOTLOADER_BOARD_NAME := q2q
TARGET_BOARD_PLATFORM := lahaina
TARGET_SOC := lahaina
TARGET_BOARD_PLATFORM_GPU := qcom-adreno660
BOARD_USES_QCOM_HARDWARE := true
QCOM_BOARD_PLATFORMS += lahaina

# 64-bit userspace. Confirm second-architecture support against stock vendor
# contents before enabling a 32-bit secondary ABI.
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := cortex-a76
TARGET_CPU_ABI2 :=

# Samsung's stock boot uses header version 3.
BOARD_BOOT_HEADER_VERSION := 3
BOARD_MKBOOTIMG_ARGS += --header_version 3
BOARD_KERNEL_PAGESIZE := 4096
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_KERNEL_CMDLINE := ignore_loglevel loglevel=8 printk.always_print_kmsg=y rodata=off clk_ignore_unused androidboot.hardware=qcom androidboot.bootdevice=1d84000.ufshc androidboot.memcg=1 lpm_levels.sleep_disabled=1 video=vfb:640x400,bpp=32,memsize=3072000 msm_rtb.filter=0x237 service_locator.enable=1 androidboot.usbcontroller=a600000.dwc3 swiotlb=2048 loop.max_part=7 cgroup.memory=nokmem,nosocket printk.devkmsg=on pcie_ports=compat cpuinfo.chipname=SM8350 panic=4 androidboot.selinux=disabled androidboot.force_normal_boot=1 androidboot.boot_recovery=0 androidboot.verifiedbootstate=orange androidboot.vbmeta.device_state=unlocked msm_drm.dsi_display0=ss_dsi_panel_S6E3FAB_AMB623ZF01_HD msm_drm.dsi_display1=ss_dsi_panel_S6E3XA2_AMF755ZE01_QXGA
# BOARD_KERNEL_SEPARATED_DTBO := true

# Build kernel from source using Android's built-in toolchain integration
TARGET_KERNEL_SOURCE := kernel/samsung/q2q
TARGET_KERNEL_CONFIG := vendor/q2q_eur_openx_defconfig
TARGET_KERNEL_ARCH := arm64
TARGET_KERNEL_CLANG_VERSION := r596125
TARGET_KERNEL_ADDITIONAL_FLAGS := KCFLAGS="-Wno-error=strict-prototypes -Wno-error=implicit-int -Wno-error=deprecated-non-prototype"

# Partition sizes: boot/vendor_boot/recovery/DTBO values are from the q2q
# recovery tree; verify them against the supplied PIT before packaging images.
BOARD_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 100663296
BOARD_CACHEIMAGE_PARTITION_SIZE := 268435456
BOARD_DTBOIMG_PARTITION_SIZE := 25165824
BOARD_FLASH_BLOCK_SIZE := 262144

# Values below come from lpdump on the SM-F926BXXSJJZH3 super image.
BOARD_SUPER_PARTITION_SIZE := 13115588608
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 13111394304
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext vendor product odm

BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4

# Explicit dynamic partition size allocations commented out to use BoardConfigCommon.mk reserved sizes
# BOARD_SYSTEMIMAGE_PARTITION_SIZE := 7516192768
# BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_SIZE := 1073741824
# BOARD_VENDORIMAGE_PARTITION_SIZE := 2147483648
# BOARD_PRODUCTIMAGE_PARTITION_SIZE := 2147483648
# BOARD_ODMIMAGE_PARTITION_SIZE := 33554432
BOARD_USES_SYSTEM_EXTIMAGE := true
BOARD_USES_PRODUCTIMAGE := true
BOARD_USES_ODMIMAGE := true
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_ODM := odm
TARGET_COPY_OUT_SYSTEM_EXT := system_ext

TARGET_OTA_ASSERT_DEVICE := q2q,q2qxxx,SM-F926B,SM-F926N,SM-F9260

# Non-A/B device configuration matching stock Samsung firmware
AB_OTA_UPDATER := false
TARGET_OTA_ALLOW_NON_AB := true

# VNDK configuration for stock vendor compatibility
BOARD_VNDK_VERSION := current

# Prebuilt vendor image, vendor_boot image, boot image, DTB, and DTBO
BOARD_PREBUILT_VENDORIMAGE := out/target/product/q2q/vendor-audio.img
BOARD_PREBUILT_VENDOR_BOOTIMAGE := device/samsung/q2q/vendor_boot.img
BOARD_PREBUILT_BOOTIMAGE := device/samsung/q2q/boot.img
BOARD_PREBUILT_DTB := device/samsung/q2q/dtb
TARGET_PREBUILT_DTBO := device/samsung/q2q/dtbo.img
# BOARD_INCLUDE_DTB_IN_BOOTIMG := true

# Ensure /metadata, /product, and /odm mount point directories exist in system root
BOARD_ROOT_EXTRA_FOLDERS += metadata product odm

# VINTF Manifest
DEVICE_MANIFEST_FILE := device/samsung/q2q/manifest.xml

# SELinux
ALLOW_PERMISSIVE_SELINUX := true
SELINUX_IGNORE_NEVERALLOWS := true
BOARD_VENDOR_SEPOLICY_DIRS += device/samsung/q2q/sepolicy/vendor
include device/qcom/sepolicy_vndr/SEPolicy.mk

# Android Verified Boot (AVB) - Enabled with disabled verification flag (--flags 3)
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_AVB_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_BOOT_ALGORITHM := SHA256_RSA4096
BOARD_AVB_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_BOOT_ROLLBACK_INDEX_LOCATION := 1

# BOARD_AVB_VENDOR_BOOT_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
# BOARD_AVB_VENDOR_BOOT_ALGORITHM := SHA256_RSA4096
# BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
# BOARD_AVB_VENDOR_BOOT_ROLLBACK_INDEX_LOCATION := 2

BOARD_AVB_RECOVERY_KEY_KEY_PATH := external/avb/test/data/testkey_rsa4096.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA4096
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 3

BOARD_AVB_SYSTEM_ADD_HASHTREE_FOOTER_ARGS := --hash_algorithm sha256
BOARD_AVB_VENDOR_ADD_HASHTREE_FOOTER_ARGS := --hash_algorithm sha256
BOARD_AVB_PRODUCT_ADD_HASHTREE_FOOTER_ARGS := --hash_algorithm sha256
BOARD_AVB_ODM_ADD_HASHTREE_FOOTER_ARGS := --hash_algorithm sha256

BOARD_VENDOR_SEPOLICY_DIRS := $(sort $(BOARD_VENDOR_SEPOLICY_DIRS))
PRODUCT_PRIVATE_SEPOLICY_DIRS := $(sort $(PRODUCT_PRIVATE_SEPOLICY_DIRS))
PRODUCT_PUBLIC_SEPOLICY_DIRS := $(sort $(PRODUCT_PUBLIC_SEPOLICY_DIRS))
