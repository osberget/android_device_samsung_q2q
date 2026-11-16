# Copyright (C) 2026 The q2q Device Tree Authors
# SPDX-License-Identifier: Apache-2.0

$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/non_ab_device.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

$(call inherit-product, device/samsung/q2q/device.mk)
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_q2q
PRODUCT_DEVICE := q2q
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-F926B
PRODUCT_MANUFACTURER := samsung
