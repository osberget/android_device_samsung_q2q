#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOP="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
PRODUCT_OUT="${PRODUCT_OUT:-$TOP/out/target/product/q2q}"
BASE_IMAGE="$TOP/device/samsung/q2q/vendor.img"
OUTPUT_IMAGE="$PRODUCT_OUT/vendor-audio.img"
HAL="${1:-$PRODUCT_OUT/vendor/lib64/hw/audio.primary.lahaina.so}"
BT_AUDIO_HAL_DIR="$TOP/out/soong/.intermediates/hardware/interfaces/bluetooth/audio/aidl/default/android.hardware.bluetooth.audio-impl"
BT_AUDIO_HAL="$(find "$BT_AUDIO_HAL_DIR" -type f \
    -path '*/android_vendor_arm64_*_shared/android.hardware.bluetooth.audio-impl.so' \
    ! -path '*/before_final_validations/*' \
    ! -path '*/unstripped/*' -print -quit 2>/dev/null)"
BT_AUDIO_VINTF="$TOP/hardware/interfaces/bluetooth/audio/aidl/default/bluetooth_audio.xml"

for tool in debugfs; do
    command -v "$tool" >/dev/null || {
        echo "Required tool not found: $tool" >&2
        exit 1
    }
done

if [[ ! -f "$BASE_IMAGE" ]]; then
    echo "Base vendor image not found: $BASE_IMAGE" >&2
    exit 1
fi
if [[ ! -f "$HAL" ]]; then
    echo "Built audio HAL not found: $HAL" >&2
    echo "Build it first with: m audio.primary.lahaina" >&2
    exit 1
fi
if [[ -z "$BT_AUDIO_HAL" || ! -f "$BT_AUDIO_HAL" ]]; then
    echo "Built Bluetooth Audio AIDL HAL not found under: $BT_AUDIO_HAL_DIR" >&2
    echo "Build android.hardware.bluetooth.audio-impl first." >&2
    exit 1
fi
if [[ ! -f "$BT_AUDIO_VINTF" ]]; then
    echo "Bluetooth Audio AIDL VINTF fragment not found: $BT_AUDIO_VINTF" >&2
    exit 1
fi

mkdir -p "$PRODUCT_OUT"
TMP_IMAGE="$OUTPUT_IMAGE.tmp.$$"
trap 'rm -f "$TMP_IMAGE"' EXIT
cp --reflink=auto "$BASE_IMAGE" "$TMP_IMAGE"

debugfs -w -R "write $HAL /lib64/hw/audio.primary.lahaina.so" "$TMP_IMAGE" >/dev/null
debugfs -w -R 'set_inode_field /lib64/hw/audio.primary.lahaina.so mode 0100644' "$TMP_IMAGE" >/dev/null
debugfs -w -R 'ea_set /lib64/hw/audio.primary.lahaina.so security.selinux u:object_r:vendor_hal_file:s0' "$TMP_IMAGE" >/dev/null
debugfs -R 'stat /lib64/hw/audio.primary.lahaina.so' "$TMP_IMAGE" | rg -q 'Type: regular.*Mode:  0644'

# The stock vendor image is used as a prebuilt, so PRODUCT_PACKAGES does not
# install the AOSP Bluetooth Audio AIDL provider into it. Add the built provider
# and its VINTF declaration to this derived image; keep device/samsung/q2q/vendor.img untouched.
debugfs -w -R "write $BT_AUDIO_HAL /lib64/android.hardware.bluetooth.audio-impl.so" "$TMP_IMAGE" >/dev/null
debugfs -w -R 'set_inode_field /lib64/android.hardware.bluetooth.audio-impl.so mode 0100644' "$TMP_IMAGE" >/dev/null
debugfs -w -R 'ea_set /lib64/android.hardware.bluetooth.audio-impl.so security.selinux u:object_r:vendor_file:s0' "$TMP_IMAGE" >/dev/null
debugfs -w -R "write $BT_AUDIO_VINTF /etc/vintf/manifest/android.hardware.bluetooth.audio.xml" "$TMP_IMAGE" >/dev/null
debugfs -w -R 'set_inode_field /etc/vintf/manifest/android.hardware.bluetooth.audio.xml mode 0100644' "$TMP_IMAGE" >/dev/null
debugfs -w -R 'ea_set /etc/vintf/manifest/android.hardware.bluetooth.audio.xml security.selinux u:object_r:vendor_configs_file:s0' "$TMP_IMAGE" >/dev/null
debugfs -R 'stat /lib64/android.hardware.bluetooth.audio-impl.so' "$TMP_IMAGE" | rg -q 'Type: regular.*Mode:  0644'
debugfs -R 'stat /etc/vintf/manifest/android.hardware.bluetooth.audio.xml' "$TMP_IMAGE" | rg -q 'Type: regular.*Mode:  0644'
debugfs -R 'cat /etc/vintf/manifest/android.hardware.bluetooth.audio.xml' "$TMP_IMAGE" | rg -q 'android.hardware.bluetooth.audio'

mv -f "$TMP_IMAGE" "$OUTPUT_IMAGE"
trap - EXIT
echo "Patched vendor image: $OUTPUT_IMAGE"
