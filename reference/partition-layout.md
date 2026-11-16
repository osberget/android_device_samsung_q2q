# Stock q2q partition evidence

Source: SM-F926B EUX stock firmware `F926BXXSJJZH3`.

`lpdump` reports a super block device size of 13,115,588,608 bytes. Its
`qti_dynamic_partitions` group has a maximum size of 13,111,394,304 bytes and
contains `system`, `vendor`, `product`, and `odm`.

The recovery device tree reports these fixed image partition sizes:

| Partition | Bytes | Source / confidence |
| --- | ---: | --- |
| boot | 100,663,296 | q2q TWRP BoardConfig; check PIT |
| vendor_boot | 100,663,296 | q2q TWRP BoardConfig; check PIT |
| recovery | 100,663,296 | q2q TWRP BoardConfig; check PIT |
| dtbo | 25,165,824 | q2q TWRP BoardConfig; check PIT |

The TWRP sizes are provisional for Lineage. Verify against `Q2Q_EUR_OPENX.pit`
before producing or flashing partition images.
