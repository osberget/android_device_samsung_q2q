#!/system/bin/sh
echo "none" > /config/usb_gadget/g1/UDC 2>/dev/null
for f in /sys/class/udc/*; do
    if [ -e "$f" ]; then
        basename "$f" > /config/usb_gadget/g1/UDC
        break
    fi
done
if [ ! -s /config/usb_gadget/g1/UDC ]; then
    echo a600000.dwc3 > /config/usb_gadget/g1/UDC 2>/dev/null
fi
