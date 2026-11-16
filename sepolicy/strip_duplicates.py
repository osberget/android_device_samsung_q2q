import sys
import re

duplicates = {
    'hal_service_type', 'protected_service', 'vendor_modprobe',
    'proc_consoles', 'sysfs_gpu', 'zram_data_file',
    'sysfs_uhid', 'proc_watermark_boost_factor', 'hal_uwb_service'
}

genfs_duplicates = {
    'proc_watermark_boost_factor', 'proc_consoles', 'sysfs_uhid', 'sysfs_gpu'
}

path = sys.argv[1]
with open(path, 'r') as f:
    lines = f.readlines()

seen_decls = set()
seen_genfs = set()
out = []

for line in lines:
    m = re.match(r"^\s*\((?:type|typeattribute)\s+([^\s\)]+)\)\s*$", line)
    if m:
        symbol = m.group(1)
        if symbol in duplicates:
            if symbol in seen_decls:
                print(f"Stripping duplicate sepolicy declaration: {symbol}")
                continue
            else:
                seen_decls.add(symbol)

    if "genfscon" in line and any(d in line for d in genfs_duplicates):
        matched_genfs = next((d for d in genfs_duplicates if d in line), None)
        if matched_genfs:
            if matched_genfs in seen_genfs:
                print(f"Stripping conflicting genfscon rule: {line.strip()}")
                continue
            else:
                seen_genfs.add(matched_genfs)

    out.append(line)

with open(path, 'w') as f:
    f.writelines(out)
