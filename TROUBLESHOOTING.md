# Troubleshooting

I will add to this file over time as users experience problems.

#### Help, I broke touchscreen and WiFi among other things after an update

This occurs because you did not run `zypper ref && zypper dup` as instructed. Instead, you either ran `zypper up` or `pkcon update`.

In other words, you updated droid-hal-pdx225-img-boot, but did not run the oneshot trigger (which `zypper dup` does for you automatically). This means `/var/lib/platform-updates/flash-bootimg.sh` never ran. 

The end result is that you have a different modules directory (`ls /lib/modules/5.4.300-qgki-*`) than kernel version `uname -r`). Because touchscreen, WiFi, sound, and more depend on kernel modules, they have stopped working.

Given that you no longer have touch input or SSH access over WiFi, you need to use a USB mouse or keyboard to navigate the phone. Using a USB mouse, you can unlock the phone, open fingerterm, and copy the existing `/lib/modules/5.4.300-qgki-` to a new folder named the same as your output from `uname -r`. After a reboot, you will have restored touch and Wifi. But you probably really need to run `devel-su /var/lib/platform-updates/flash-bootimg.sh`.

If I can get usb-moded working, you could also SSH over USB to do the above. Currently, if you do not own a mouse that you can plug into the USB-C port, I think you will have to manually download [droid-hal-pdx225-img-boot-0.0.1-1.2.3.bso.aarch64](https://repo.sailfishos.org/obs/nemo:/testing:/hw:/sony:/murray:/5.1/sailfishos_5.1_aarch64/aarch64/droid-hal-pdx225-img-boot-0.0.1-1.2.3.bso.aarch64.rpm), open it with an archive manager, extract boot/hybris-boot.img, put the phone into bootloader mode, and run `fastboot flash hybris-boot.img`.
