#!/system/bin/sh
# Load all vendor kernel modules from modules.load, then any remaining .ko files
if [ -f /vendor/lib/modules/modules.load ]; then
    while read -r m; do
        [ -n "$m" ] && insmod "/vendor/lib/modules/$m" 2>/dev/null
    done < /vendor/lib/modules/modules.load
fi

for f in /vendor/lib/modules/*.ko; do
    [ -f "$f" ] && insmod "$f" 2>/dev/null
done
