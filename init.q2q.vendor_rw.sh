#!/system/bin/sh
echo "=== Q2Q VENDOR_RW EXECUTED ===" > /dev/kmsg

# Mirror /vendor/etc to writable tmpfs
mkdir -p /dev/vendor_etc_rw
mount -t tmpfs -o size=32M,mode=0755 tmpfs /dev/vendor_etc_rw
cp -a /vendor/etc/* /dev/vendor_etc_rw/ 2>/dev/null

# Copy camxoverridesettings.txt into vendor/etc/camera
mkdir -p /dev/vendor_etc_rw/camera
if [ -f /system/etc/q2q_camera/camxoverridesettings.txt ]; then
    cp /system/etc/q2q_camera/camxoverridesettings.txt /dev/vendor_etc_rw/camera/
fi

# Update fstab files for unencrypted /data
for f in /dev/vendor_etc_rw/fstab.*; do
    if [ -f "$f" ]; then
        sed -i 's/fileencryption=[^[:space:]]*//g; s/keydirectory=[^[:space:]]*//g; s|/data.*f2fs.*|&,encryptable=footer|; s|/data.*ext4.*|&,encryptable=footer|' "$f"
    fi
done

# Bind mount writable /dev/vendor_etc_rw over /vendor/etc
mount none /dev/vendor_etc_rw /vendor/etc bind
echo "=== Q2Q VENDOR_RW BIND MOUNT COMPLETE ===" > /dev/kmsg

setprop vendor.q2q.vendor_rw.done 1
