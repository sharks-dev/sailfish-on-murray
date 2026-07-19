# Installing the *testing* image:

*Note: these instructions may not be the most efficient way of getting the job done, but they worked for me. If someone wishes to revise them please let me know.*
*Additionally, remember that my device is an XQ-CC72. In theory, these images should work identically on an XQ-CC54 (as the LineageOS images do), but until someone tries it I can't be sure.*

First, ensure your device is running stock Android 14 from Sony. If you have previously flashed SailfishOS or unlocked the bootloader for any other reason, you will have to reflash to stock with XperiaFirm and NewFlasher or similar.

Once fully upgraded to the latest Android 14 from Sony, head to the [LineageOS downloads page](https://web.archive.org/web/20251123023550/https://download.lineageos.org/devices/pdx225/builds) (archived) to get the latest LineageOS 22.2 build for pdx225. You will need to download `lineage-22.2-20251009-nightly-pdx225-signed.zip` and the associated `dtbo.img` and `vbmeta.img`.

Follow the [LineageOS installation instructions](https://web.archive.org/web/20250418165834/https://wiki.lineageos.org/devices/pdx225/install/#) (archived) to install LineageOS to your device. Ensure you download and flash `copy-partitions-20220613-signed.zip` when instructed. Reboot into LineageOS and confirm functionality.

Reboot to recovery, and flash `copy-partitions-20220613-signed.zip` again. This ensures both slots a and b contain LineageOS.

Reboot to bootloader and run `fastboot set_active a` to ensure we end up flashing Sailfish in slot a.

Using the [Sailfish images downloaded & extracted from my Github](https://github.com/sharks-dev/sailfish-on-murray/releases), run `fastboot flash dtbo dtbo.img && fastboot flash boot hybris-boot.img && fastboot flash userdata sailfish.img001 && fastboot reboot`.

Your device will sit on the SONY screen for a minute or two, then Sailfish should show up.
