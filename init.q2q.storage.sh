#!/system/bin/sh

log -t q2q-storage "Waiting for Android boot completion before repairing user 0 storage"

# The CE-available property can be set before the framework is fully ready.
tries=0
while [ "$(getprop sys.boot_completed)" != "1" ] && [ "$tries" -lt 90 ]; do
    sleep 2
    tries=$((tries + 1))
done

if [ "$(getprop sys.boot_completed)" != "1" ]; then
    log -t q2q-storage "Boot did not complete in time; leaving storage unchanged"
    exit 1
fi

log -t q2q-storage "Repairing /data/media/0 permissions and emulated volume"

mkdir -p /data/media/0/DCIM/Camera \
    /data/media/0/Download \
    /data/media/0/Pictures
chown -R 1023:1023 /data/media/0
chmod -R 0775 /data/media/0
restorecon -RF /data/media/0

content call --uri content://media --method scan_volume --arg external_primary
sm unmount 'emulated;0' 2>/dev/null
sleep 1
sm mount 'emulated;0'
sleep 1

am force-stop com.android.providers.media.module
am force-stop com.android.externalstorage
content call --uri content://media --method scan_volume --arg external_primary
sm unmount 'emulated;0' 2>/dev/null
sleep 1
sm mount 'emulated;0'

log -t q2q-storage "Storage repair sequence completed"
