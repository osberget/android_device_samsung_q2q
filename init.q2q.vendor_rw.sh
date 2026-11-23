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

# Mirror /vendor/lib64 to writable tmpfs and overlay all vendor bluetooth audio dependencies
mkdir -p /dev/vendor_lib64_rw
mount -t tmpfs -o size=512M,mode=0755 tmpfs /dev/vendor_lib64_rw
cp -a /vendor/lib64/* /dev/vendor_lib64_rw/ 2>/dev/null
for lib in android.hardware.bluetooth.audio-V6-ndk.so android.hardware.audio.common-V5-ndk.so libbluetooth_audio_session_aidl.so android.hardware.bluetooth.audio@2.0.so android.hardware.bluetooth.audio@2.1.so libbluetooth_audio_session.so; do
    if [ -f "/system/etc/q2q_bt_libs/$lib" ]; then
        cp "/system/etc/q2q_bt_libs/$lib" /dev/vendor_lib64_rw/
        chmod 0644 "/dev/vendor_lib64_rw/$lib"
        chcon u:object_r:vendor_file:s0 "/dev/vendor_lib64_rw/$lib"
    fi
done
mount none /dev/vendor_lib64_rw /vendor/lib64 bind

# Mirror /vendor/lib64/hw to writable tmpfs and overlay vendor-compiled audio.bluetooth.default.so
mkdir -p /dev/vendor_lib64_hw_rw
mount -t tmpfs -o size=32M,mode=0755 tmpfs /dev/vendor_lib64_hw_rw
cp -a /vendor/lib64/hw/* /dev/vendor_lib64_hw_rw/ 2>/dev/null
if [ -f /system/etc/q2q_bt_libs/hw/audio.bluetooth.default.so ]; then
    cp /system/etc/q2q_bt_libs/hw/audio.bluetooth.default.so /dev/vendor_lib64_hw_rw/
    chmod 0644 /dev/vendor_lib64_hw_rw/audio.bluetooth.default.so
    chcon u:object_r:vendor_file:s0 /dev/vendor_lib64_hw_rw/audio.bluetooth.default.so
fi
mount none /dev/vendor_lib64_hw_rw /vendor/lib64/hw bind

echo "=== Q2Q VENDOR_RW BIND MOUNT COMPLETE ===" > /dev/kmsg

setprop vendor.q2q.vendor_rw.done 1
