#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
TOP="$(cd -- "$SCRIPT_DIR/../../../.." && pwd)"
PRODUCT_OUT="${PRODUCT_OUT:-$TOP/out/target/product/q2q}"
BASE_IMAGE="$TOP/device/samsung/q2q/vendor.img"
OUTPUT_IMAGE="$PRODUCT_OUT/vendor-audio.img"
HAL="${1:-$PRODUCT_OUT/vendor/lib64/hw/audio.primary.lahaina.so}"

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

mkdir -p "$PRODUCT_OUT"
TMP_IMAGE="$OUTPUT_IMAGE.tmp.$$"
trap 'rm -f "$TMP_IMAGE"' EXIT
cp --reflink=auto "$BASE_IMAGE" "$TMP_IMAGE"

debugfs -w -R "write $HAL /lib64/hw/audio.primary.lahaina.so" "$TMP_IMAGE" >/dev/null
debugfs -w -R 'set_inode_field /lib64/hw/audio.primary.lahaina.so mode 0100644' "$TMP_IMAGE" >/dev/null
debugfs -w -R 'ea_set /lib64/hw/audio.primary.lahaina.so security.selinux u:object_r:vendor_hal_file:s0' "$TMP_IMAGE" >/dev/null
debugfs -R 'stat /lib64/hw/audio.primary.lahaina.so' "$TMP_IMAGE" | rg -q 'Type: regular.*Mode:  0644'

mv -f "$TMP_IMAGE" "$OUTPUT_IMAGE"
trap - EXIT
echo "Patched vendor image: $OUTPUT_IMAGE"
