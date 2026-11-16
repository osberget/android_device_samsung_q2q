# Walkthrough - LineageOS 24 Bringup on Samsung Galaxy Z Fold 3 (q2q)

We have successfully diagnosed, engineered, and resolved multiple complex architecture gaps required to bring up LineageOS 24 (Android 17) on the Samsung Galaxy Z Fold 3 (`q2q`) using stock `vendor.img` and `vendor_boot.img`.

## Accomplishments

1. **Kernel & Boot Bringup**:
   - Configured clean stock DTB, 4MB stock DTBO, and source-built kernel with BTI protection disabled for `init_first_stage`.
   - Patched `libfs_avb` (`IsDeviceUnlocked`) and `first_stage_init.cpp` to correctly mount dynamic ext4 partitions and bypass AVB checks.
   - Configured `recovery.fstab` for unencrypted `/data` and secondary partitions with `nofail`.

2. **Linker & Firmware Fixes**:
   - Fixed the `/system/bin/linker64` symlink to point to `/system/bin/bootstrap/linker64`.
   - Resolved `ipa_fws` firmware loading failure by removing incorrect `firmware_class.path` from `BoardConfig.mk`.

3. **Health HAL & VINTF Manifest**:
   - Resolved `hwservicemanager` health HAL timeout (`android.hardware.health@2.0::IHealth/default`) by implementing `health-interface-provider` in `init.q2q.system.rc` mapped to Samsung's vendor binary `/vendor/bin/hw/android.hardware.health@2.1-service-samsung`.

4. **SELinux Compatibility**:
   - Added `30.0.cil` and `30.0.compat.cil` to `/system/etc/selinux/mapping/` to support Android 11 (`30.0`) vendor sepolicy.
   - Built a custom `boot.img` with `androidboot.selinux=disabled`.

5. **Early USB ADB Bringup**:
   - Fixed ConfigFS USB Gadget protocol in `init.q2q.system.rc` (enforcing `symlink` of `ffs.adb` *before* writing to `UDC`).
   - Enabled `start adbd` during early boot.
