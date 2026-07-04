# sailfish-on-murray
LineageOS 22.2 based SailfishOS for Sony Xperia 10 IV


## Refer to:

https://github.com/sharks-dev/droid-config-pdx225

https://github.com/sharks-dev/android_kernel_sony_sm6375

https://github.com/sharks-dev/droid-hal-version-pdx225

https://github.com/sharks-dev/droid-hal-pdx225

# Getting Lineage

It seems that lineageos.org do not host older versions of Lineage for this device(?)

The latest build of Lineage 22.2 is available from an archived version of their site at this URL: https://web.archive.org/web/20251123023550/https://download.lineageos.org/devices/pdx225/builds

The flashing instructions can be found likewise: https://web.archive.org/web/20250418165834/https://wiki.lineageos.org/devices/pdx225/install/#

## Notes

On my machine (i7-6700, 32GB, Debian 13), from scratch, building SFOS 5.1.0.10, as of 02/07/2026:
- `repo sync` writes 182.12 GB to $ANDROID_ROOT
- `make -j$(nproc --all) hybris-hal droidmedia` takes 1hr 57mins, produces 28.33 GB of data in out/
- `rpm/dhd/helpers/build_packages.sh --mic` requires a final 1.03 GB, including the resultant 537 MB flashable *.zip

Don't forget to run `make audio.hidl_compat.default`

Don't forget to run `rpm/dhd/helpers/build_packages.sh --mw=https://github.com/sailfish-on-nabu/parse-android-dynparts`

Ensure you're flashing to slot_a, as parse-android-dynparts seems incompatible with slot_b(?)

Run `fastboot erase userdata && fastboot format:ext4 userdata` before flashing (to ensure userdata is not encrypted by Android. Note you cannot use the fastboot 34.0.5-debian for this, you must download the latest fastboot 37.0.0-14910828 at the time of writing).

LineageOS recovery can't unzip a bzip2, you must bunzip2 the rootfs and adjust hybris-updater-script and hybris-updater-unpack inside the produced *.zip before flashing.

LineageOS recovery can't fathom the idea of booting something that isn't Android - when it notices Android isn't booting, it will reboot to recovery and show some error message. Thus, after flashing I reboot to bootloader and run `fastboot flash boot hybris-recovery.img`, then reboot.

## HADK guides used for this port:

https://sailfishos.org/content/uploads/2022/02/SailfishOS-HardwareAdaptationDevelopmentKit-4.3.0.15.pdf (outdated)

https://github.com/mer-hybris/hadk-faq#android-base-specific-fixes

https://sailfishos.wiki/books/hardware/page/hadk-hot#bkmrk-hybris-18%C2%A0-wip

https://piggz.co.uk/sailfishos-porters-archive/index.php

## Also handy 

Official SODP based murray port: https://github.com/mer-hybris/droid-config-sony-murray/

And another LOS22 based port by VerandiTeam: https://github.com/VerdandiTeam/droid-config-miami

An earlier attempt at a LOS based X10IV port(?) by @piggz, @Kabouik and @NotKit: https://github.com/NotKit/droid-config-halium-pdx225

# Acknowledgements
Thanks to @mal, @elros34 and others who provided (and are still providing!) help and advice on #sailfishos-porters.
