# Samsung Galaxy Z Fold3 5G (SM-F926B, q2q)

Initial native LineageOS device-tree bring-up for the European SM-F926B.
This is a work in progress and is not build-ready yet.

## Confirmed source material

- Stock firmware: `F926BXXSJJZH3` (EUX), downloaded under the adjacent
  `SAMFW.COM_SM-F926B_EUX_F926BXXSJJZH3_fac` directory.
- Samsung kernel source: `SM-F926B_15_Opensource/Kernel`.
- Kernel version: Linux 5.4.274.
- Kernel defconfig: `vendor/q2q_eur_openx_defconfig`.
- Kernel DTS files: `arch/arm64/boot/dts/samsung/q2/q2q/`.
- SoC/platform: Qualcomm SM8350 / `lahaina`, Adreno 660.
- Stock `boot` and `vendor_boot` header versions: 3; page size: 4096.
- Stock vendor_boot contains the DTB and a first-stage ramdisk with
  `fstab.qcom`; the unmodified stock fstab is kept in `reference/` only.
- Stock super metadata contains logical partitions `system`, `vendor`,
  `product`, and `odm`, grouped as `qti_dynamic_partitions`.
- q2q TWRP device tree used as a reference:
  <https://gitlab.com/azkali-samsung/q2q/twrp/android_device_samsung_q2q>

## Current status

The initial Lineage product files and verified board identity are in place.
The q2q TWRP tree is recovery-specific; its partition and image settings are
references, not assumed to be correct for Lineage packaging. The Samsung
kernel source and stock images have not yet been integrated into a Lineage
build. No vendor blobs or Lineage-specific fstab/init/SELinux policy have
been generated yet.

## Next bring-up work

1. Extract stock `vendor`, `product`, `odm`, and firmware files, then create
   the audited `proprietary-files.txt` list and generated `vendor/samsung/q2q`
   makefiles.
2. Verify the raw partition sizes and flashing layout against
   `Q2Q_EUR_OPENX.pit` before building flashable images.
3. Adapt the stock fstab and vendor_boot ramdisk for Lineage; do not use the
   reference fstab unchanged.
4. Integrate the Samsung kernel source at `kernel/samsung/q2q`, apply the
   JJZH3 source update to its matching full source baseline, and connect its
   q2q defconfig/build steps.
5. Add the q2q init scripts, overlays, SELinux policy, and hardware service
   configuration required for Android 17, then iterate using boot logs.

## Notes

`PRODUCT_SHIPPING_API_LEVEL` and vendor VNDK details should be confirmed from
stock build properties before they are set. The framework device tree is
separate from the kernel's DTS files and from the TWRP recovery tree.
