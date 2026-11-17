#!/system/bin/sh
MOD_DIR="/vendor/lib/modules/5.4-gki"
if [ ! -d "$MOD_DIR" ]; then
    MOD_DIR="/vendor/lib/modules"
fi

if [ -f "$MOD_DIR/modules.load" ]; then
    while read -r m; do
        [ -n "$m" ] && insmod "$MOD_DIR/$m" 2>/dev/null
    done < "$MOD_DIR/modules.load"
fi

for f in "$MOD_DIR"/*.ko; do
    [ -f "$f" ] && insmod "$f" 2>/dev/null
done

setprop vendor.all.modules.ready 1
