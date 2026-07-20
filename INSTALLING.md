# Installing the *testing* image:

*Note: these instructions may not be the most efficient way of getting the job done, but they worked for me. If someone wishes to revise them please let me know.*
*Additionally, remember that my device is an XQ-CC72. In theory, these images should work identically on an XQ-CC54 (as the LineageOS images do), but until someone tries it I can't be sure.*

First, flash stock firmware. I did this by plugging into [Xperia Flash Tool](https://opendevices.sony.net/aosp-on-xperia-open-devices/get-started/flash-tool), which shot me back to Android 12.
![Reflashing stock OS](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/1_reflashing_stock.jpg?raw=true|height=100) ![Flashed to Sony A12](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/2_stock_A12.jpg?raw=true|height=100)

In order to install Lineage, we need to start with Android 14, so I downloaded version 65.2.A.2.270 with [XperiaFirm](https://xperifirmtool.com/), and flashed that with [NewFlasher](https://github.com/munjeni/newflasher).
![Flashed to Sony A14](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/3_stock_A14.jpg?raw=true|height=100)

Once fully upgraded to the latest Android 14 from Sony, I headed to the [LineageOS downloads page](https://web.archive.org/web/20251123023550/https://download.lineageos.org/devices/pdx225/builds) (archived) to get the latest LineageOS 22.2 build for pdx225. You will need to download lineage-22.2-20251009-nightly-pdx225-signed.zip and the associated dtbo.img and vbmeta.img. The *.zip file is also mirrored at [lineage-archive.timschumi.net](https://lineage-archive.timschumi.net/build/35983).
![Flashing Lineage](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/4_Lineage_Recovery.jpg?raw=true|height=100)

I then followed the [LineageOS installation instructions](https://web.archive.org/web/20250418165834/https://wiki.lineageos.org/devices/pdx225/install/#) (archived) to install LineageOS to your device. At this stage, I rebooted into LineageOS and confirmed functionality.
![Booting Lineage](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/5_Lineage_boot.jpg?raw=true|height=100) ![Flashed to Lineage 22.2](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/6_Lineage_A15.jpg?raw=true|height=100)

Rebooting into recovery again, you'll note we're running in slot b. For Sailfish to work, we need to be in slot a. The best way to do this, as far as I can work out, is to flash `copy-partitions-20220613-signed.zip` (from the LineageOS installation instructions) again, then reflash `lineage-22.2-20251009-nightly-pdx225-signed.zip` also. When you reboot to recovery after this, you'll note we're back in slot a. This is because the Lineage flashing zip always flashes to the currently "inactive" slot, so Android 14 -> Lineage was A->B, and Lineage->Lineage was B->A.
![The active slot is 'b'](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/7_Active_Slot_B.jpg?raw=true|height=100) ![The active slot changed to 'a'](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/8_Active_Slot_A.jpg?raw=true|height=100)

So, now that we are finally running Lineage in slot a, we can flash Sailfish! Download the latest build from the [Releases section of this repo](https://github.com/sharks-dev/sailfish-on-murray/releases).

Reboot to bootloader, and run `fastboot flash dtbo dtbo.img && fastboot flash boot hybris-boot.img && fastboot flash userdata sailfish.img001 && fastboot reboot`. The first boot will take a few minutes where you'll be stuck on the SONY logo, but you will eventually get the Sailfish setup wizard.
![Stuck on the SONY screen for a bit](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/9_Sailfish_is_booting.jpg?raw=true|height=100) ![Woo! We're in!](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/10_Sailfish_has_booted.jpg?raw=true|height=100)
![Nearly there...](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/11_Getting_In.jpg?raw=true|height=100) ![Sailfish 5.1.0.11 is running fine!](https://github.com/sharks-dev/sailfish-on-murray/blob/main/images/12_Sailfish_5_1_0_11.jpg?raw=true|height=100)

I must thank @mettska for helping me realise out I'd made a mistake in the previous version of these instructions and forgotten to flash Lineage back into slot a. If you get stuck at any point, please reach out on the Sailfish Forums and I'll get back to you.
