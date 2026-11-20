#!/system/bin/sh
if [ "$(getprop vendor.q2q.vendor_rw.done)" = "1" ]; then
    echo "=== Q2Q VENDOR_RW ALREADY COMPLETE; SKIPPING ===" > /dev/kmsg
    exit 0
fi

echo "=== Q2Q VENDOR_RW EXECUTED ===" > /dev/kmsg
setprop vendor.q2q.vendor_rw.done 0

fail() {
    echo "=== Q2Q VENDOR_RW FAILED: $1 ===" > /dev/kmsg
    exit 1
}

# Mirror /vendor/etc to writable tmpfs
mkdir -p /dev/vendor_etc_rw
mount -t tmpfs -o size=512M,mode=0755 tmpfs /dev/vendor_etc_rw || fail "tmpfs mount"
cp -a /vendor/etc/. /dev/vendor_etc_rw/ || fail "copy /vendor/etc"

# Copy camxoverridesettings.txt into vendor/etc/camera
mkdir -p /dev/vendor_etc_rw/camera || fail "create camera config directory"
if [ -f /system/etc/q2q_camera/camxoverridesettings.txt ]; then
    cp /system/etc/q2q_camera/camxoverridesettings.txt /dev/vendor_etc_rw/camera/camxoverridesettings.txt || fail "copy camera overrides"
fi

# The Lahaina MTP audio HAL expects this device-name-specific mixer file.
cp -f /dev/vendor_etc_rw/mixer_paths.xml /dev/vendor_etc_rw/mixer_paths_mtp.xml || fail "copy MTP mixer paths"

# Apply the vendor configuration label before exposing this tree at /vendor/etc.
chcon -R u:object_r:vendor_configs_file:s0 /dev/vendor_etc_rw || fail "label vendor configs"

# Bind mount from PID 1's mount namespace so all services see the overlay.
/system/bin/nsenter -t 1 -m -- /system/bin/mount --bind /dev/vendor_etc_rw /vendor/etc || fail "bind mount /vendor/etc in PID 1 mount namespace"
echo "=== Q2Q VENDOR_RW BIND MOUNT COMPLETE ===" > /dev/kmsg

setprop vendor.q2q.vendor_rw.done 1
