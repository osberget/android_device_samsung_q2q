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

# Copy updated audio_policy_configuration.xml
if [ -f /system/etc/audio_policy_configuration.xml ]; then
    cp /system/etc/audio_policy_configuration.xml /dev/vendor_etc_rw/
fi

# Copy bluetooth_audio.xml into vendor/etc/vintf/manifest/
mkdir -p /dev/vendor_etc_rw/vintf/manifest
if [ -f /system/etc/q2q_bluetooth_audio.xml ]; then
    cp /system/etc/q2q_bluetooth_audio.xml /dev/vendor_etc_rw/vintf/manifest/bluetooth_audio.xml
    chmod 0644 /dev/vendor_etc_rw/vintf/manifest/bluetooth_audio.xml
    chcon u:object_r:vendor_configs_file:s0 /dev/vendor_etc_rw/vintf/manifest/bluetooth_audio.xml
fi

# Copy q2q_audio_effects.xml into vendor/etc/audio_effects.xml
if [ -f /system/etc/q2q_audio_effects.xml ]; then
    cp /system/etc/q2q_audio_effects.xml /dev/vendor_etc_rw/audio_effects.xml
    chmod 0644 /dev/vendor_etc_rw/audio_effects.xml
    chcon u:object_r:vendor_configs_file:s0 /dev/vendor_etc_rw/audio_effects.xml
fi

# Update fstab files for unencrypted /data
for f in /dev/vendor_etc_rw/fstab.*; do
    if [ -f "$f" ]; then
        sed -i 's/fileencryption=[^[:space:]]*//g; s/keydirectory=[^[:space:]]*//g; s|/data.*f2fs.*|&,encryptable=footer|; s|/data.*ext4.*|&,encryptable=footer|' "$f"
    fi
done

# Bind mount writable /dev/vendor_etc_rw over /vendor/etc
mount none /dev/vendor_etc_rw /vendor/etc bind

# Overlay /vendor/lib64 with overlayfs to layer all vendor bluetooth audio dependencies without copying 512MB
mkdir -p /dev/q2q_v64_up/hw /dev/q2q_v64_wk
cp /system/etc/q2q_bt_libs/*.so /dev/q2q_v64_up/ 2>/dev/null
cp /system/etc/q2q_bt_libs/hw/audio.bluetooth.default.so /dev/q2q_v64_up/hw/ 2>/dev/null
chmod 0755 /dev/q2q_v64_up /dev/q2q_v64_up/hw
chmod 0644 /dev/q2q_v64_up/*.so /dev/q2q_v64_up/hw/*.so
chcon -R u:object_r:vendor_file:s0 /dev/q2q_v64_up
mount -t overlay overlay -o lowerdir=/vendor/lib64,upperdir=/dev/q2q_v64_up,workdir=/dev/q2q_v64_wk /vendor/lib64

echo "=== Q2Q VENDOR_RW BIND MOUNT COMPLETE ===" > /dev/kmsg

setprop vendor.q2q.vendor_rw.done 1
