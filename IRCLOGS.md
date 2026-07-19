# irclogs

Using [sailfishIRC-localArchiver](https://github.com/starkDbl07/sailfishIRC-localArchiver#) and some quick bash scripting, I've pulled all the relevant logs to this port from #sailfishos-porters and put them here for future reference. You can of course always [grep the archives yourself](https://piggz.co.uk/sailfishos-porters-archive/index.php), but this makes life easier if you're looking for the history of what I went through in getting this port to work. It might be a handy reference if I ever run into any of the same issues again, or if someone else comes along wanting to port the X10V and doesn't want to make the same mistakes I did.

Hopefully I don't come off as too much of a whinger when you read it.


---
### 📅 2026-06-22

| Time | User & Message |
| :--- | :--- |
| 07:24:48 | *&lt;sharks&gt;*: Hi all - I am attempting to flash my first image to my device, no doubt many more to come as I debug things, but I have run into a problem straightaway. https://paste.opensuse.org/pastes/77dc76936720 |
| 07:24:49 | *&lt;sharks&gt;*: I am using the LineageOS recovery from my Android base system, and I initially land at `ERROR: recovery error: 21` where "signature verification failed", but I can opt to continue anyway on the phone. |
| 07:24:56 | *&lt;sharks&gt;*: Beyond that, I fail to mount /data "invalid argument", and then fail to unpack the tarball with "tar: exec bzip2: no such file or directory". |
| 07:25:01 | *&lt;sharks&gt;*: I believe both of these last two errors to be showstoppers. Can anyone please assist me on potential ways to resolve them? |
| 08:53:42 | *&lt;sharks&gt;*: Okay - as a temporary workaround I ran `adb reboot bootloader`, `fastboot flash boot hybris-boot.img`, and `fastboot reboot recovery` - now I have the phone booted, though I can't get telnet - ethernet is up but lsusb reports "iProduct 2 Failed to boot init in real rootfs". I will investigate... |
| 09:00:06 | *&lt;sharks&gt;*: Ooh - scratch that, I do have telnet. |
| 09:07:20 | *&lt;sharks&gt;*: Okay - back to square one, just like in /tmp/recovery.log from LOS recovery, init.log shows I can't mount /data. Reading up on it, maybe because it's encrypted? Even though I wiped it in the LOS recovery? |
| 09:07:22 | *&lt;sharks&gt;*: + mount /dev/sda74 /data -- mount: mounting /dev/sda74 on /data failed: Invalid argument |
| 09:22:30 | *&lt;sharks&gt;*: I am unsure how to get an unencrypted, mountable userdata. Hadk-hot just says to format it in recovery before attempting to flash SFOS but I have already tried that? |
| 09:35:30 | *&lt;sharks&gt;*: Wahoo! `fastboot erase userdata` and `fastboot format:ext4 userdata` worked! Now I can mount /data from recovery! But I still cannot flash my .zip because `tar: exec bzip2: No such file or directory` |
| 09:53:46 | *&lt;sharks&gt;*: Okay, made a new .zip after bunzip2'ing the sailfish rootfs tar.bz2 and changing the line in updater-unpack.sh to `tar -xvf` rather than `tar xvjf`. Now I can sucessfully flash! But after booting the system it makes it past the SONY screen and automatically reboots to LOS recovery saying "your data may be currupt, reason: init_user0_failed". So I have no idea if SFOS works or if LOS is getting in the way. |
| 09:59:23 | *&lt;sharks&gt;*: Trying my previous trick of flashing hybris-boot directly now briefly brings up the network interface before it dies again. Device is not rebooting, stays on the SONY screen. Cannot telnet due to network interface going down almost as soon as it goes up. I think this is it for the night, will resume tinkering tomorrow |
| 10:08:47 | **&lt;elros34&gt;**: @sharks creating /data/.stowaways/sailfishos/init_enter_debug2 will let you telnet at 2323 port |
| 12:17:37 | <mark>&lt;mal&gt;</mark>: PSA: it's recommended to use pulseaudio-modules-droid version 14.2.106 with Sailfish OS 5.1, the latest version has significant changes which most likely require the changes in various other packages |

---
### 📅 2026-06-23

| Time | User & Message |
| :--- | :--- |
| 09:28:58 | *&lt;sharks&gt;*: Is it at all possible to port SailfishOS using LineageOS recovery or do I need to port TWRP first? |
| 11:19:03 | **&lt;elros34&gt;**: @sharks it doesn't matter which one do you use or not use any |

---
### 📅 2026-06-25

| Time | User & Message |
| :--- | :--- |
| 10:03:02 | *&lt;sharks&gt;*: Alright, I'm stuck again - I have attempted to get parse-android-dynparts working, have added it to patterns, built the rpm, added `/usr/bin/droid/dmsetup.sh`, and `dmsetup.service`, `vendor.mount`, etc. to `/usr/lib/systemd/system/`. Finally I put `%define makefstab_skip_entries / vendor` in `droid-hal-device.spec`. |
| 10:03:06 | *&lt;sharks&gt;*: But after rebuilding droid-hal and trying to recreate the rootfs with `build_packages.sh --mic`, I get "file /usr/lib/systemd/system/vendor.mount conflicts between attempted installs of droid-config-....aarch64 and droid-hal-....aarch64" |
| 10:03:10 | *&lt;sharks&gt;*: Clearly I have missed a step but I'm too much of a novice to work out what it is. Can anyone please point me in the right direction? |
| 11:33:41 | <mark>&lt;mal&gt;</mark>: sharks: you need to skip the mount point generation for the partitions that are handled with parse-android-dynparts, something like this in droid-hal spec https://github.com/mlehtima/droid-hal-fp5/blob/master/droid-hal-fp5.spec#L25 |
| 14:06:56 | **&lt;elros34&gt;**: @sharks if you have added '/ vendor' then that is your issue, it's '/vendor' |

---
### 📅 2026-06-26

| Time | User & Message |
| :--- | :--- |
| 10:21:07 | *&lt;sharks_&gt;*: @elros34 - thanks for picking up on my typo, that was the issue! It's the smallest thing that catches you out sometimes. |
| 10:29:24 | *&lt;sharks_&gt;*: Unfortunately now that I've got my new rootfs, I'm still not able to mount /vendor. Though the usb network interface stays up for a good 30 seconds now, I still don't get far enough to have telnet working. Would anybody be willing to lend a hand overnight? Journal attached -> https://paste.opensuse.org/pastes/6fdc467ad3ab |
| 16:19:39 | **&lt;elros34&gt;**: @sharks_ did you enable dmsetup? I do not see it in log. Log is very noisy, add audit=0 to kernel cmdline |

---
### 📅 2026-06-27

| Time | User & Message |
| :--- | :--- |
| 12:16:44 | *&lt;sharks&gt;*: @elros34 - thanks again, I had enabled it but when I rebuilt the rootfs my simlinks weren't there? I was too tired to keep debugging and gave up for the night. Thanks for spotting it, added the symlinks on the device and it got considerably further. |
| 12:23:35 | *&lt;sharks&gt;*: I could once again do with another hand - possibly because I'm too tired to think straight again - but I think I've got all the filesystems mounted, I'm struggling to spot now where things are getting stuck? Kernel seems to work, droid-hal-init is starting and not failing, though hwservicemanager is struggling to get graphics up. Additionally, the USB network interface comes up and goes down again nearly straight away, so still can't telne |
| 12:24:29 | *&lt;sharks&gt;*: If anyone more experienced than me would be willing to have another look I'd appreciate it. Thanks for all your help so far @mal and @elros34. Journal attached -> https://paste.opensuse.org/pastes/06c503ff21e1 |
| 12:30:37 | *&lt;sharks&gt;*: Ooh maybe it's those lines way towards the end about linker? `Warning: failed to find generated linker configuration from "/linkerconfig/ld.config.txt"` and `Hanging forever because setup failed: Unable to open hwrng /dev/hw_random`? |
| 12:32:28 | <mark>&lt;mal&gt;</mark>: sharks: which android base? |
| 12:32:32 | <mark>&lt;mal&gt;</mark>: noticed one issue |
| 12:33:43 | *&lt;sharks&gt;*: @mal - based on Lineage22.2 |
| 12:34:22 | *&lt;sharks&gt;*: What did you notice? |
| 12:35:40 | <mark>&lt;mal&gt;</mark>: "executing /usr/libexec/droid-hybris/system/bin/linkerconfig failed: No such file or directory" |
| 12:36:08 | *&lt;sharks&gt;*: Yep, cool - you're looking in the same spot I am. Thanks for confirming. |
| 12:36:49 | <mark>&lt;mal&gt;</mark>: go to $ANDROID_ROOT/rpm/dhd and check what is the last git commit there |
| 12:39:49 | <mark>&lt;mal&gt;</mark>: update that submodule to latest version anyway |
| 12:40:01 | <mark>&lt;mal&gt;</mark>: and then build_packages.sh -d and try what happens |
| 12:41:21 | *&lt;sharks&gt;*: Hmm, it is up to date, nothing has changed in a month? |
| 12:42:09 | *&lt;sharks&gt;*: Latest commit I have is be67bbc, which matches remote mer-hybris/droid-hal-device |
| 12:42:41 | <mark>&lt;mal&gt;</mark>: hmm, then how can it be missing |
| 12:43:06 | <mark>&lt;mal&gt;</mark>: run "find out/target/product -name linkerconfig" |
| 12:46:22 | *&lt;sharks&gt;*: `out/target/product/pdx225/obj/EXECUTABLES/linkerconfig.com.android.runtime_intermediates/linkerconfig`, `out/target/product/pdx225/symbols/apex/com.android.runtime/bin/linkerconfig`, `out/target/product/pdx225/recovery/root/linkerconfig`, `out/target/product/pdx225/root/linkerconfig` |
| 12:47:51 | <mark>&lt;mal&gt;</mark>: there is supposed to be one in out/target/product/$DEVICE/apex/com.android.runtime/bin/linkerconfig |
| 12:48:08 | <mark>&lt;mal&gt;</mark>: why is it not there |
| 12:48:57 | <mark>&lt;mal&gt;</mark>: looks like it's not there in my build either, let me check a bit |
| 12:52:42 | *&lt;sharks&gt;*: No worries, thanks mal. Let me know what you find |
| 12:55:13 | <mark>&lt;mal&gt;</mark>: you could remove the last commit from system/core which adds the new path for linkerconfig |
| 12:56:04 | *&lt;sharks&gt;*: What's the thinking behind that? |
| 12:56:49 | <mark>&lt;mal&gt;</mark>: or maybe I have a better idea |
| 12:57:42 | <mark>&lt;mal&gt;</mark>: in rpm/dhd you have this https://github.com/mer-hybris/droid-hal-device/blob/master/droid-hal-device.inc#L788 |
| 12:58:01 | *&lt;sharks&gt;*: two secs I will check |
| 12:58:41 | *&lt;sharks&gt;*: Yes I do |
| 13:00:03 | <mark>&lt;mal&gt;</mark>: so make a duplicate of those lines 788-792 and in the duplicate change part "apex/com.android.runtime/bin/linkerconfig" to "obj/EXECUTABLES/linkerconfig.com.android.runtime_intermediates/linkerconfig" |
| 13:02:08 | *&lt;sharks&gt;*: Cool, done. Now I re-run `build_packages.sh -d`? |
| 13:03:07 | <mark>&lt;mal&gt;</mark>: yes |
| 13:04:21 | *&lt;sharks&gt;*: Fantastic, thanks mal. Will let you know how I get on in the morning, past 11pm now I'm nackered |
| 13:39:30 | *&lt;sharks&gt;*: Apologies, not sticking around to see replies, will get back to you in the morning, but have rebuilt the image and got a new journal log. As far as I can see not much change? https://paste.opensuse.org/pastes/d87b88286cb4 |
| 13:39:52 | *&lt;sharks&gt;*: I am signing off for the night, will get back to it tomorrow. Thanks again |
| 14:29:02 | <mark>&lt;mal&gt;</mark>: some issues I see in the log, you need to add "Requires: libgbinder-tools" to droid-config spec like this https://github.com/mlehtima/droid-config-fp5/blob/master/rpm/droid-config-fp5.spec#L31 also the android tad service is failing, from what I understand that is important on sonys, I found another issue also which I will fix in hybris-patches (issue that will slow down boot and can cause random |
| 14:29:08 | <mark>&lt;mal&gt;</mark>: failures) |
| 14:53:43 | **&lt;elros34&gt;**: enabled kernel ratelimiting will hide some messages from you, disable it. Did you copy /etc/task_profiles.json as in hadk-hot? |

---
### 📅 2026-06-28

| Time | User & Message |
| :--- | :--- |
| 01:30:29 | *&lt;sharks&gt;*: Alright - this morning I've added libgbinder-tools and fixed task_profiles, thanks @mal and @elros34. Still seem no further along though. Struggling to find information on this 'tad' service. Yet to disable ratelimiting, will do that on the next boot. journal -> https://paste.opensuse.org/pastes/c413d729d224 |
| 02:41:39 | *&lt;sharks&gt;*: I can't work out why the usb network interface goes down almost as quick as it comes up. The logs don't seem like there's much going catastrophically wrong? droid-hal-init is making it all the way through. It looks like we're all but ready to start lipstick but we can't load android.hardware.graphics.composer. I would have thought I should have telnet by now at the very least. |
| 03:51:11 | *&lt;sharks&gt;*: Alright, I'm taking a break. I think the problem is something to do with binder or linker but I don't know enough about what I'm doing to get further than that. |
| 07:21:18 | **&lt;elros34&gt;**: @sharks if you have problem with usb then why dont you try what hadk-hot suggest and mask usb-modded? It's so common issue, just read instruction |
| 07:25:12 | **&lt;elros34&gt;**: then you will have acces to logcat which might reveal why it fails |

---
### 📅 2026-06-29

| Time | User & Message |
| :--- | :--- |
| 06:30:07 | *&lt;sharks&gt;*: Woohoo! With a bit more screwing around I have telnet! And more importantly, logcat! And I can debug on a live system now! |
| 06:30:50 | *&lt;sharks&gt;*: Unfortunately @mal was dead right, it seems this `tad` service is the killer, logcat is spammed constantly with `tadif   : Failed to connect to tad.` |
| 07:59:42 | &lt;securebootoff&gt;: tad is ta daemon |
| 07:59:58 | &lt;securebootoff&gt;: you'll get broken modem, mac addresses, etc without it |
| 08:09:25 | *&lt;sharks&gt;*: hmm, that's what I thought, it wouldn't hold up boot. That said, still want to fix it. |
| 08:11:27 | *&lt;sharks&gt;*: I am also still fighting android.hardware.graphics.composer - is there a best practice to edit / override `/vendor/etc/vintf/manifest.xml`? It is missing any section about android.hardware.graphics.composer which I suspect is the issue? Unless I am barking up the wrong tree? |
| 08:12:56 | &lt;adampigg&gt;: you can bind mount over the top of it with a modified version (re @SailfishFreenodeIRCBridgeBot: <sharks>I am also st...) |
| 08:30:33 | *&lt;sharks&gt;*: Thanks piggz, I did not spot your reply until now - I am trying that but do not know where to put the command to bind mount! If I put it in droid-hal-early-init.sh is that sufficient? |
| 08:50:55 | *&lt;sharks&gt;*: Right, here's some hopefully relevant lines from logcat, journal, and the vintf manifest that I have bind-mounted to a modified file from droid-hal-early-init.sh --> https://paste.opensuse.org/pastes/3c904aeca69a |
| 08:51:17 | *&lt;sharks&gt;*: I freely admit I have no idea what I am doing, but if anyone can help I would be grateful |
| 08:53:45 | *&lt;sharks&gt;*: I don't know if this offers any insight either --> https://paste.opensuse.org/pastes/c520fb1990c7 |
| 09:29:31 | **&lt;elros34&gt;**: droid-hal-early-init is executed before droid-hal-init (android init) so yes. If you have no idea then would be better to not filter out logs but shows everything right? |
| 09:43:09 | *&lt;sharks&gt;*: The logcat file is too big to upload to opensuse, mainly its full of megabytes of `tadif   : Failed to connect to tad.` but even with all that cut out it's still over the limit, I'll do my best |
| 09:45:14 | **&lt;elros34&gt;**: no, that is not how do you generate logs. You get them as soon as possible/include all early logs. Several MB of repeated logs 2 minutes after boot are useless |
| 09:45:41 | *&lt;sharks&gt;*: I understand that, elros. These logs are collected as soon as I can telnet in and dump to file. They are only a few seconds old. |
| 09:48:59 | **&lt;elros34&gt;**: why would you dump to file? just print it. Also for sure you can get them even faster with init_enter_debug2 and then excuting logcat as soon as droid-hal-init starts |
| 09:52:32 | *&lt;sharks&gt;*: How is it easier to print 70,000 lines of logcat to my terminal window and try to copy it out of there? simpler just to run logcat > somefile.txt. Anyway, it is done now. logcat -> https://paste.opensuse.org/pastes/6e241e7fe837 and journal -> https://paste.opensuse.org/pastes/440f4a200dd7 |
| 09:54:26 | *&lt;sharks&gt;*: You are right I probably could get faster / shorter logs with init_enter_debug2, I guess I will do that next time. Thanks |
| 10:00:22 | **&lt;elros34&gt;**: this journal is only 30s |
| 10:00:50 | **&lt;elros34&gt;**: so have you tried to start/strace this tad service? |
| 10:03:33 | *&lt;sharks&gt;*: Yes, the journal is only 30s. I got it as soon as I telnet'd in like I said |
| 10:04:58 | *&lt;sharks&gt;*: No, I have not tried to strace tad. I have been more focused on the composer as that seemed like the fish that I might be able to fry a bit easier |
| 10:05:14 | *&lt;sharks&gt;*: But I will try to strace tad now |
| 10:06:05 | **&lt;elros34&gt;**: as soon as fast doesn;t mean only 30s. 30s is usual timeout. Try to reenable vold service and see if that will help with hwcomposer |
| 10:10:23 | *&lt;sharks&gt;*: result of strace --> https://paste.opensuse.org/pastes/feddd2bf08e7 |
| 10:12:03 | *&lt;sharks&gt;*: journal longer than 30s --> https://paste.opensuse.org/pastes/c2f8e48351eb |
| 10:13:55 | *&lt;sharks&gt;*: I apologise, I am unsure how to 'reenable vold service'. I never disabled it, but I can see in journal logs it is failing? |
| 10:15:17 | **&lt;elros34&gt;**: based on logs it's probably in 'Parsing file /usr/libexec/droid-hybris/system/etc/init/disabled_services.rc'. Btw do you have some services masked? |
| 10:15:31 | **&lt;elros34&gt;**: sailfish services* |
| 10:16:34 | *&lt;sharks&gt;*: I only have usb-moded masked per your suggestion a few days ago to allow telnet to work |
| 10:17:18 | **&lt;elros34&gt;**: ok |
| 10:17:42 | *&lt;sharks&gt;*: Yes, looks like vold is in disabled_services.rc -> `service vold vold_HYBRIS_DISABLED`. I will remove it and reboot, see what happens? |
| 10:25:00 | *&lt;sharks&gt;*: short answer, enabling vold was a bad idea |
| 10:25:43 | *&lt;sharks&gt;*: see journal, vold kills the system after a few minutes --> https://paste.opensuse.org/pastes/543d4f9e80dc |
| 10:25:51 | *&lt;sharks&gt;*: Phone ends up rebooting |
| 10:27:49 | **&lt;elros34&gt;**: ah because it has reboot_on_failure property and it fails |
| 10:28:26 | *&lt;sharks&gt;*: appears that way, yes |
| 10:30:11 | *&lt;sharks&gt;*: Why is vold trying to open system_a directly? It is already mounted...? |
| 10:35:00 | **&lt;elros34&gt;**: no idea how it works internally. About that tad. From where did you get whole command to run it? |
| 10:35:35 | *&lt;sharks&gt;*: Ah, good question, give me a minute to reboot and I will find it again |
| 10:37:01 | **&lt;elros34&gt;**: ah so from /odm/etc/init/init.sony.rc? |
| 10:37:16 | *&lt;sharks&gt;*: Yes |
| 10:37:53 | **&lt;elros34&gt;**: can yo ushow it? |
| 10:38:10 | *&lt;sharks&gt;*: The whole file? hold on will upload |
| 10:39:30 | **&lt;elros34&gt;**: you have also also some service with miscta in name, check whether it works and do not restart |
| 10:39:37 | *&lt;sharks&gt;*: https://paste.opensuse.org/pastes/b0c18fa15614 |
| 10:41:55 | **&lt;elros34&gt;**: I guess it woul dbe good idae to strace it directly in rc file, it starts with some custom user/group |
| 10:42:40 | *&lt;sharks&gt;*: I'm sorry, I am still learning how to do all this stuff. Would you mind elaborating? What is the best way to go about doing that? |
| 10:43:13 | **&lt;elros34&gt;**: I need to remember/find exact command |
| 10:43:32 | *&lt;sharks&gt;*: thanks |
| 10:48:37 | **&lt;elros34&gt;**: mkdir -m777 /data/strace/ and then change that line which starts tad  to "service tad /usr/bin/strace -ff -s256 -o /data/strace/tad.strace /vendor/bin/tad /dev/block/bootdevice/by-name/TA 0,16". I guess you can override it in disabled_services.rc ir that partition is not writiable |
| 10:51:27 | **&lt;elros34&gt;**: I wonder where is failing lipstick in your logs |
| 10:51:40 | *&lt;sharks&gt;*: I was googling while you worked that out and found a similar solution, same command but I did another bind-mount in early-init.sh to be able to edit the file. Output here --> https://paste.opensuse.org/pastes/6286d37be510 |
| 10:53:38 | *&lt;sharks&gt;*: I assumed lipstick failed because the composer is failing? Seemed to make sense to me as a novice that the graphical environment would fail if the graphics hardware wasn't able to work |
| 10:53:56 | *&lt;sharks&gt;*: But I don't see where in the logs there is really any mention of lipstick |
| 10:57:54 | **&lt;elros34&gt;**: openat(AT_FDCWD, "/dev/block/bootdevice/by-name/TA", O_RDWR\|O_SYNC) = -1 EACCES (Permission denied) |
| 10:59:37 | *&lt;sharks&gt;*: You reckon that's the killer? I don't know how to fix it but I'll start researching if you don't have any ideas |
| 10:59:39 | **&lt;elros34&gt;**: I'm wondering why there is no 'Trim Area using TA version 3' in logcat, clearly binary prints it somwhere. Can you start including commands you are executing |
| 11:00:04 | **&lt;elros34&gt;**: not just output |
| 11:00:38 | **&lt;elros34&gt;**: most obvious would be ls -al /dev/block/bootdevice/by-name/TA |
| 11:02:13 | *&lt;sharks&gt;*: Okay device has been up for 15 mins or so therefore not uploading full logcat but "TA version 3" is in logcat. `/usr/libexec/droid-hybris/system/bin/logcat \| grep TA` outputs "Trim Area using TA version 3.", "Failed to open /dev/block/bootdevice/by-name/TA (Permission denied)", and "Failed to configure TA library." spammed repeatedly every few ms |
| 11:02:32 | &lt;nikita_kraev&gt;: Any way to support `parse-android-dynparts` for system_b / system_ext_b / any kind of _b slots? I am only getting _a from the mapper (link: https://gist.github.com/nikita-kraev/800409d366bfb7863911ec1bb2871cf5), i can surely reflash hybris-boot in partition a, but i am wondering if there is a way |
| 11:02:53 | *&lt;sharks&gt;*: `ls -al /dev/block/bootdevice/by-name/TA` --> "lrwxrwxrwx    1 root     root            15 Jun  5 18:39 /dev/block/bootdevice/by-name/TA -> /dev/block/sda1" |
| 11:03:48 | *&lt;sharks&gt;*: @nikita_kraev I found the same thing and just reflashed to _a, but I am not the smartest fellow here so I am sure there is a way |
| 11:04:51 | &lt;nikita_kraev&gt;: yeah, i'll probably do that as well, just need to update my systemd mappings since i hardcoded them to have _b slots |
| 11:05:16 | *&lt;sharks&gt;*: Lol I did that too! |
| 11:05:58 | **&lt;elros34&gt;**: @sharks so how this is not included in logcat you uploaded. this strace was simply waste of time if all info are in logs |
| 11:07:10 | *&lt;sharks&gt;*: Probably because the logcat I uploaded was of early boot as requested. As I said the device has been up for a long time now so by now the logcat is mostly spam about tad failing. |
| 11:10:19 | **&lt;elros34&gt;**: ok so always provide logs which include: all early messages + 2 minutes after boot. I guess this is because this strange idea to pipe everything to file. What about ls -al dev/block/sda1? does it have also rwx for everybody? |
| 11:11:41 | *&lt;sharks&gt;*: example of current `/usr/libexec/droid-hybris/system/bin/logcat` output spam --> https://paste.opensuse.org/pastes/3bc5ece48c13 |
| 11:12:28 | *&lt;sharks&gt;*: `ls -al dev/block/sda1` --> "lrwxrwxrwx    1 root     root             7 Jun  5 18:39 dev/block/sda1 -> ../sda1" |
| 11:14:29 | **&lt;elros34&gt;**: keep digging untill its no longer symlink |
| 11:15:02 | *&lt;sharks&gt;*: `ls -al dev/sda1` --> "brw-rw----    1 root     disk        8,   1 Jun  5 18:39 dev/sda1" |
| 11:15:48 | *&lt;sharks&gt;*: Sorry, I should have realised that needed doing. |
| 11:16:06 | *&lt;sharks&gt;*: So are the permissions of /dev/sda1 the problem? |
| 11:16:15 | **&lt;elros34&gt;**: pff no need to. I was also just guessing. |
| 11:16:38 | *&lt;sharks&gt;*: Haha okay |
| 11:17:15 | **&lt;elros34&gt;**: change to oem_2997 root or add rwx to 'other' group too and see what will happend |
| 11:26:08 | *&lt;sharks&gt;*: Yes, I think that fixed tad! --> logcat output: https://paste.opensuse.org/pastes/296def3b03c7, strace: https://paste.opensuse.org/pastes/26fd4b67d1db |
| 11:26:54 | *&lt;sharks&gt;*: Now logcat spam about tad has gone away, we have cleared up room for all the other logcat spam to come to life: https://paste.opensuse.org/pastes/c1693edce2e5 |
| 11:28:03 | *&lt;sharks&gt;*: Anyway I appreciate your help elros and thanks for putting up with me as I'm learning. Unfortunately it is getting quite late and I have work at 6am tomorrow, so I need to put this aside for the night. If you have any further suggestions I will action them tomorrow after work. Thankyou again |
| 11:39:25 | **&lt;elros34&gt;**: one less spamming service for the win |

---
### 📅 2026-06-30

| Time | User & Message |
| :--- | :--- |
| 09:08:41 | *&lt;sharks&gt;*: Woo! I'm getting somewhere!! https://imgur.com/a/j0cMbem |
| 09:09:46 | *&lt;sharks&gt;*: Nothing works, but at least I have a screen |
| 09:10:06 | *&lt;sharks&gt;*: Probably a bit early to celebrate tbh |
| 09:41:32 | *&lt;sharks&gt;*: Holy shite the camera works lol --> https://imgur.com/a/CaU3is1 |
| 09:41:52 | *&lt;sharks&gt;*: How about that? An Xperia 10 IV running sailfishOS with a working camera, never thought I'd see the day |
| 09:42:30 | *&lt;sharks&gt;*: If I can get sound and wifi and phone calls out of this thing now I'll be a happy man |
| 09:52:10 | **&lt;elros34&gt;**: so what was the issue with not working gui? |
| 09:56:22 | *&lt;sharks&gt;*: I came across `test_hwcomposer` in the porters logs, when I ran that I got a display which proved to me that we could talk to the hardware. |
| 09:57:02 | *&lt;sharks&gt;*: I still don't know why I get `Control message: Could not find 'android.hardware.graphics.composer@2.1::IComposer/default'` in journal, but that goes away once you actually manage to put something on the screen |
| 09:57:49 | *&lt;sharks&gt;*: Anyway then I tracked down how lipstick starts and started it manually / strace / etc, trying to debug it. Worked out it's looking for a touchscreen at /dev/input/event4, which did not exist. After running modprobe sec_ts_drv the touchscreen appeared at /dev/input/event3, and once I pointed lipstick to that it fired right up. |
| 09:58:37 | *&lt;sharks&gt;*: So I wrote some very bodgy fixes into droid-hal-early-init.sh and now can reboot the device and bring up the display reliably\ |
| 09:58:47 | *&lt;sharks&gt;*: now I just have to clean that up and do it properly |
| 10:00:02 | **&lt;elros34&gt;**: didn't you have just evdevtouch in https://github.com/mer-hybris/droid-hal-configs/blob/master/sparse/var/lib/environment/compositor/droid-hal-device.conf? |
| 10:00:46 | **&lt;elros34&gt;**: it should autodetect touchscreen node by default |
| 10:01:44 | *&lt;sharks&gt;*: Yes I think the problem is that there was no touchscreen in /dev/input/event3 until I ran `modprobe sec_ts_drv` |
| 10:02:16 | *&lt;sharks&gt;*: sorry, in /dev/input/* anywhere. All I had was buttons and a switch for when the USB disconnects. |
| 10:02:26 | *&lt;sharks&gt;*: So I need to work out why that is missing |
| 10:05:30 | **&lt;elros34&gt;**: not so important but just it doesn't matter whether there is /dev/input/event3 or not if you don't hardcode any node in droid-hal-device.conf |
| 10:07:07 | *&lt;sharks&gt;*: So /dev/input/. can be an empty directory and the hardware still works? |
| 10:10:29 | **&lt;elros34&gt;**: no I am only talking about autodetection of touchscreen node in lipstick/qt |
| 10:13:06 | *&lt;sharks&gt;*: Ah sorry I understand now, yes /dev/input/event4 was hardcoded in the file, I changed that to /dev/input/event3 and put `modprobe sec_ts_drv` in early-init.sh and that fixed things. But I think the modprobe command should not be in that script? So I need to figure a cleaner way to do that. |
| 10:13:35 | *&lt;sharks&gt;*: I have now changed the file to autodetect per your suggestion and can confirm that works too. I like that solution better, thanks |
| 10:19:05 | **&lt;elros34&gt;**: https://github.com/mlehtima/droid-config-fp5/blob/master/sparse/etc/modules-load.d/fp5.conf |
| 10:20:37 | **&lt;elros34&gt;**: but you seams to have |
| 10:20:38 | **&lt;elros34&gt;**: ``` |
| 10:20:39 | **&lt;elros34&gt;**: sec_ts_drv: disagrees about version of symbol module_layout in logs``` |
| 10:21:41 | **&lt;elros34&gt;**: so could be reason why it's not autoloaded |
| 10:23:51 | *&lt;sharks&gt;*: Thanks - I just came across modules-load.d, was about to go down that route but good spot, I wonder why we get that warning. You could be right, maybe it is trying to autoload but is failing. I wonder why it works when I load it manually? |
| 10:26:31 | **&lt;elros34&gt;**: I guess first try is in initramfs |
| 10:31:53 | *&lt;sharks&gt;*: Yes could be there. I think to be honest I will just put it in modules-load.d for now and come back to it later if it's a problem. |
| 10:37:04 | **&lt;elros34&gt;**: also check for  other maybe useful modules you want to add there which now fail with: "disagrees about version of symbol module_layout" |
| 10:40:43 | *&lt;sharks&gt;*: hmm there are a few, I'll work on that. Thanks. Chances are some of them are related to other bits of the hardware I'm yet to make work |
| 10:42:01 | &lt;nikita_kraev&gt;: how do we tackle the "disagrees about version of symbol xxx" in general? |
| 10:44:52 | &lt;Mister_Magister&gt;: you just ignore it and it works anyway |
| 10:47:36 | &lt;nikita_kraev&gt;: lol okay, that's what i was planning to do anyway :D |
| 10:49:29 | *&lt;sharks&gt;*: Haha too easy |
| 11:02:43 | <mark>&lt;mal&gt;</mark>: @nikita_kraev what gives that error? |
| 11:04:08 | &lt;Mister_Magister&gt;: mal android's modprobe |
| 11:40:44 | &lt;Mister_Magister&gt;: mal: from what I gathered, and I might be wrong, because I have same issue on my device, it's from android wanting to modprobe from vendor |
| 11:48:12 | &lt;Mister_Magister&gt;: I could be wrong tho |
| 11:53:52 | &lt;nikita_kraev&gt;: yeah, it's Android modprobe, only happens in droid-hal-init i think, i am currently masking ins_modprobe, so don't have it in the latest logs unfortunately |
| 11:54:37 | <mark>&lt;mal&gt;</mark>: well you should make sure the modules get loaded, a bit like how I did on fp5 https://github.com/mlehtima/droid-config-fp5/blob/master/sparse/etc/modules-load.d/fp5.conf |

---
### 📅 2026-07-01

| Time | User & Message |
| :--- | :--- |
| 07:07:02 | *&lt;sharks&gt;*: Still making progress, I added all modules in `out/target/product/pdx225/vendor_dlkm/lib/modules/modules.load` to `/etc/modules-load.d/pdx225.conf`, plus also `wlan`, and added wifisetup.service same as fp5. Now I have vibration, LED and wifi working. Still no sound, ofono or bluetooth. But getting a little bit closer all the time... |
| 07:14:01 | *&lt;sharks&gt;*: Oh also no battery or charging status |
| 07:14:15 | *&lt;sharks&gt;*: If I can get those couple of things fixed I'll be back to daily driving this thing! |
| 07:27:23 | *&lt;sharks&gt;*: Charging appears fine in `udevadm monitor -p`, but csd can't spot it. Usb sucessfully asks for developer mode or MTP or charging only but no response on the computer end for either of the first two options. |
| 07:27:44 | *&lt;sharks&gt;*: (I have unmasked usb-moded btw now that I have ssh over wifi) |
| 07:28:05 | *&lt;sharks&gt;*: Anyway reading hadk-hot etc. to see what else I can try |
| 07:31:29 | *&lt;sharks&gt;*: "sm5038_usbpd_get_property PRESENT" is changing on usb connect/disconnect in dmesg, amongst many other messages. Also I remember MTP and developer mode never worked on stock SFOS by Jolla so mayyybe charging is working? But I have no battery icon in status bar... |
| 07:44:01 | *&lt;sharks&gt;*: `/sys/class/power_supply/battery/status` changes from "discharging" to "not charging" when plugged in, huh |
| 08:05:49 | *&lt;sharks&gt;*: `/sys/class/power_supply/battery/input_current_limit` is 0 and idk how to change it, that's probably not helping |
| 10:39:45 | **&lt;elros34&gt;**: @sharks did you add hw-settings.ini file? |
| 10:55:30 | *&lt;sharks&gt;*: Jeez, @elros34, right as I'm about to go to bed I spot that. Hangon, have just added it now. Gah I miss the most obvious things! |
| 10:55:47 | *&lt;sharks&gt;*: Haha! Now we have charging. Thanks! |
| 10:57:16 | *&lt;sharks&gt;*: Audio and Ofono are my biggest hurdles now, still really struggling to work out how to attack them. Was hoping to rely on whatever Mister_Magister did to make miami work but reading the logs it seems like everything just fell into place right out of the box for him! Maybe just my lack of experience |
| 11:06:58 | *&lt;sharks&gt;*: Hmm nevermind I have a battery indicator and the notification says we're charging but `/sys/class/power_supply/battery/status` still only says "Not Charging" when USB is connected |
| 11:10:54 | *&lt;sharks&gt;*: and also cameras still work in csd-tool but now the camera app is a black screen and not responding |
| 11:26:05 | *&lt;sharks&gt;*: I need to find out what service `iddd` is and fix that, and I need to fix `android.hardware.sensors` which I only just realised is a problem. I will work on that and fixing the camera again tomorrow. Meanwhile, if anyone has any suggestions regarding audio, ofono and bluetooth, please point me in the right direction if you can. |
| 11:26:06 | *&lt;sharks&gt;*: Current logcat -> https://paste.opensuse.org/pastes/b7589a6cd7bf Journal -> https://paste.opensuse.org/pastes/41818aade5a7 and dmesg -> https://paste.opensuse.org/pastes/62aea1b73678 |
| 15:11:05 | **&lt;elros34&gt;**: @sharks: do you have /vendor/firmware_mnt? Where are you repositories droid-config and device repo? |

---
### 📅 2026-07-02

| Time | User & Message |
| :--- | :--- |
| 06:03:20 | *&lt;sharks&gt;*: @elros34 re: your message last night, yes I have /vendor/firmware_mnt, contains two directories (image and verinfo). |
| 06:04:06 | *&lt;sharks&gt;*: repos at https://github.com/sharks-dev/droid-config-pdx225 |
| 07:31:07 | *&lt;sharks&gt;*: What doesn't work is my battery indicator again after reflashing. Last time that was fixed because I forgot 10-hwsettings.ini but that's definitely there now |
| 09:09:08 | *&lt;sharks&gt;*: What's the minimum stuff I have to rebuild if I change patterns-sailfish-device-adaption `Requires:` lines? |
| 10:53:27 | &lt;nikita_kraev&gt;: config, middleware (if added something non-standard) and mic (re @SailfishFreenodeIRCBridgeBot: <sharks>What's the m...) |
| 10:53:42 | &lt;nikita_kraev&gt;: (i think, I'd wait for someone more experienced to confirm) |
| 12:15:45 | *&lt;sharks&gt;*: Shit yeah, I have bluetooth and ofono!! |
| 12:16:10 | *&lt;sharks&gt;*: I still need audo and proximity and light sensors, but otherwise I'm so nearly done. |
| 12:16:38 | *&lt;sharks&gt;*: Well past bedtime though so I'll have to take that win for the night. Can't work on it tomorrow, will try to get audio on the weekend I guess |
| 12:17:08 | *&lt;sharks&gt;*: If anyone is curious, bluetooth and ofono problems were fixed by putting the correct lines in the patterns files |
| 12:17:28 | *&lt;sharks&gt;*: Again, I miss the simplest things - but at least I'm learning |
| 13:08:45 | **&lt;elros34&gt;**: no matter what "correct lines" you add to patterns there is no point of rebuilding middleware |
| 16:15:49 | **&lt;elros34&gt;**: @sharks not sure what android version do you use because in one place you have hybris-22 in other android_version_major 14 (lineage-21) but anyway you have copied disabled_services.rc from some random device so you have some unnneded services started like bpfloader or vendor.audio-hal. Use this one instead https://github.com/mer-hybris/droid-hal-configs/blob/master/sparse-15/usr/libexec/droid-hybris/system/etc/init/disabled_services.rc or fro |

---
### 📅 2026-07-03

| Time | User & Message |
| :--- | :--- |
| 11:07:38 | *&lt;sharks&gt;*: @elros34 thankyou - I had copied disabled_sercives.rc according to hadk-faq but I'm unsurprised to learn that's out of date. I have also fixed the wrong android version, that must have been a typo by me. |
| 11:15:07 | *&lt;sharks&gt;*: Unfortunately my biggest hold up is still audio. I also have no battery indicator, ambient light sensor, or proximity sensor. I'm really struggling to debug audio, pulseaudio is segfaulting trying to run create_audio_patch though I have just found @ecrn had the same problem a few years ago so maybe the logs from 2024-12-04 could help me if I can decipher what they mean |
| 11:33:44 | *&lt;sharks&gt;*: Right, I added `https://github.com/mer-hybris/droid-config-sony-murray/blob/master/sparse/etc/pulse/arm_droid_card_custom.pa` but included `use_legacy_stream_set_parameters=true` on the module-droid-card line and now pulseaudio no longer segfaults immediately but I still have no sound :( |
| 11:51:49 | *&lt;sharks&gt;*: All audio is going to sink.deep_buffer and then disappearing, there's nothing in logcat or anywhere. |
| 12:35:24 | *&lt;sharks&gt;*: Will `pulseaudio-modules-droid-jb2q` help me? |
| 12:48:44 | *&lt;sharks&gt;*: I think not |
| 12:57:57 | *&lt;sharks&gt;*: Okay, I'm exhausted, can't seem to get anywhere. Made next to no progress for 2 days now :(( |
| 12:58:20 | *&lt;sharks&gt;*: I really should not have spent so much time on this tonight but oh well |
| 13:19:51 | **&lt;elros34&gt;**: only 2 days with no progress? pff you are lucky. You add a lot changes to droid-config like custom droid-hal-init.service. Does it fix something or some random copy from other device:P |
| 13:24:41 | &lt;Mister_Magister&gt;: took me half a year to bring up screen on my first port |
| 13:28:10 | &lt;nikita_kraev&gt;: oof that's what i am preparing for |
| 13:30:49 | **&lt;elros34&gt;**: @sharks about that battery indicator: are you sure you have /usr/share/csd/settings.d)/hw-settings.ini on device? |
| 13:33:00 | **&lt;elros34&gt;**: how do you check sensors? in csd or messwerk? |

---
### 📅 2026-07-04

| Time | User & Message |
| :--- | :--- |
| 01:07:41 | *&lt;sharks&gt;*: @elros34 lots of changes to droid-config are as a result of you pointing out sparse-15/.../disabled_services.rc. If I am running Android 15, should I have everything from sparse-15? I copied it all in and it fixed some errors in logcat/journal about gpu service and got the LED working more reliably, so I assumed it was a good thing. |
| 01:08:51 | *&lt;sharks&gt;*: And yes I definitely have hw-settings.ini on device. Can see battery status in apps & `cat /sys/class/power_supply/battery/capacity`, but not in menu bar |
| 01:10:33 | *&lt;sharks&gt;*: Have checked sensors in csd. Accelerometer is all zeros, proximity and light sensors are also unresponsive. Also, I thought volume keys not working was a product of pusleaudio being dead, but now I've fixed that (still no sound) I've got the volume slider in settings no longer greyed out yet volume keys still don't work. They are present it /dev/input/event* though |
| 04:47:15 | *&lt;sharks&gt;*: Holy heck I've got audio |
| 04:47:20 | *&lt;sharks&gt;*: All is right in the world again |
| 04:48:31 | *&lt;sharks&gt;*: Thanks again to @mal for having been here and done that, I copied to my device https://github.com/mlehtima/droid-config-fp4/blob/devel/sparse/usr/lib/systemd/system/vendor-lib64-hw-audio.primary.default.so.mount and built https://github.com/mlehtima/android_vendor_halium_hardware/tree/halium-15.0, now it's working |
| 04:48:38 | *&lt;sharks&gt;*: idk about calls yet but I don't even care lol |
| 05:01:48 | *&lt;sharks&gt;*: Shit, at some point I broke VoLTE and didn't realise it. No calls for me. VoLTE is mandatory here |
| 06:58:06 | *&lt;sharks&gt;*: After reverting the commit where I copied everything in from sparse-15, I am registered on VoLTE again but the LED no longer works and I can confirm no audio during calls. Drat. |
| 08:15:21 | **&lt;elros34&gt;**: you don't copy anything from submodule unless you need to edit particular file. Everything is copied automatically |
| 08:19:34 | **&lt;elros34&gt;**: you have typo in droid-hal-device.conf but not sure if that will case any issue |
| 08:22:59 | **&lt;elros34&gt;**: in /usr/lib64/qt5/qml/Sailfish/Lipstick/BatteryStatusIndicator.qml change visible: deviceInfo.hasFeature(DeviceInfo.FeatureBattery) to visible: true |
| 08:27:03 | **&lt;elros34&gt;**: about sensors: check sensorfw output |
| 10:43:17 | *&lt;sharks&gt;*: @elros34 - thanks, fixed typo, changing to `visible: true` fixes the battery indicator but I wonder why it isn't picking up from hw-settings.ini? sensorfw only says "sensorfw: Plugin not available: "orientationsensor"" and "sensorfw: SensorManagerError:  "plugin not available"" |
| 10:55:43 | **&lt;elros34&gt;**: @sharks what about ssu-sysinfo -f? |
| 11:08:01 | *&lt;sharks&gt;*: @elros34 `ssu-sysinfo -f` -> "Feature_Suspend" and "Feature_Reboot" |
| 11:35:14 | **&lt;elros34&gt;**: only 2? |
| 11:37:44 | *&lt;sharks&gt;*: @elros34 yeah, just those two. Nothing else |
| 11:40:02 | **&lt;elros34&gt;**: so it's wrong strace it |
| 11:41:16 | *&lt;sharks&gt;*: Sorry, you'll have to help me work that one through my thick skull. What am I stracing? ssu-sysinfo? sensorfwd? I am not sure what is responsible for making the sensors work. |
| 11:44:11 | **&lt;elros34&gt;**: strace -f ssu-sysinfo -f |
| 11:44:31 | **&lt;elros34&gt;**: ssu-sysinfo should return a lot more features |
| 11:47:14 | *&lt;sharks&gt;*: Ah drat, I just did sensorfwd! `strace /usr/sbin/sensorfwd -c=/etc/sensorfw/primaryuse.conf --systemd --log-level=warning --no-magnetometer-bg-calibration` is here --> https://paste.opensuse.org/pastes/5995134f46c9 and `strace -f ssu-sysinfo -f` is here --> https://paste.opensuse.org/pastes/22f50959b8a3 |
| 11:48:02 | **&lt;elros34&gt;**: ls -al /usr/share/csd/settings.d |
| 11:50:06 | *&lt;sharks&gt;*: oh crap is that it? I've got 10-hwsettings.ini but yesterday you called it hw-settings.ini |
| 11:50:25 | *&lt;sharks&gt;*: Where did I get 10-hwsettings.ini from? Why have I got the wrong filename? |
| 11:52:01 | **&lt;elros34&gt;**: @sharks don't ask me you put it there. right file and name is in hadk-faq |
| 11:52:22 | *&lt;sharks&gt;*: Nah mate, not asking you, just marvelling at my own stupidity. Thanks for your help |
| 11:54:29 | **&lt;elros34&gt;**: looks like it must be hw-settings sharks: https://github.com/sailfishos/ssu-sysinfo/blob/master/lib/ssusysinfo.c#L594 |
| 11:56:19 | **&lt;elros34&gt;**: for a while you had IVI mode activated:) |
| 11:57:41 | *&lt;sharks&gt;*: Hmm, it has helped in some ways and broken things in others, csd-tool now crashes when I try to test my newly configured sensors, but IMEIs now show up in settings->about and battery in status bar is finally fixed |
| 12:02:09 | **&lt;elros34&gt;**: maybe that is not a main issue. hard to guess without crash log |
| 12:09:25 | *&lt;sharks&gt;*: Okay nevermind sensors for now, I've been trying to debug VoLTE for ages and finally realised that setting %define android_version_major back to 14 allows VoLTE to register, but if set to 15 it never works |
| 12:11:46 | *&lt;sharks&gt;*: So I guess if there is no downside to it being 14 can I leave it there? Or is there a downside I don't know about? |
| 12:14:08 | **&lt;elros34&gt;**: but why. Can't you simply compare 2 directories wnd findout why or read logs to see difference? |
| 12:17:28 | **&lt;elros34&gt;**: after a while submodule will get updated and will struggle with something stopped working because you use wrong version |
| 12:22:32 | *&lt;sharks&gt;*: Well yes I probably could compare the directories, but manually copying back the working files is not a permanent solution is it? Because next time you build a new image you'll overwrite it? |
| 12:23:00 | *&lt;sharks&gt;*: Or do you manually copy back the working files to sparse so they can never change maybe? |
| 12:29:39 | *&lt;sharks&gt;*: Hmm, I think setting android version to 14 broke the microphone, but it fixed the volume keys... |
| 12:29:51 | *&lt;sharks&gt;*: I'm somewhere in between android 14 and 15 apparently |
| 12:33:17 | *&lt;sharks&gt;*: Yeah, also youtube videos have diagonal lines all through them now but local videos play alright. Dang. I guess I have to compare the differences between these two builds and cherry pick all the right files from each one somehow |
| 12:36:36 | <mark>&lt;mal&gt;</mark>: sharks: you should not mount audio module like that, the devel branch is old, I do it differently now |
| 12:59:49 | *&lt;sharks_&gt;*: I've put porting SFOS away for the night but now you've got me pulling out my laptop on the couch and researching again... how do you do it now? I can't even see any mention of audio in the fp4 master branch. |
| 13:15:26 | <mark>&lt;mal&gt;</mark>: I think I handled it with linkerconfig, which android base do you use? |
| 13:43:29 | *&lt;sharks&gt;*: @mal I am using Lineage 22.2 |
| 13:54:16 | *&lt;sharks&gt;*: Ah I think I know why it seems like I'm somewhere between A14 and A15 - my super partition will be A14 because that's what the stock Xperia firmware goes to, but vbmeta, dtbo and the Android system are provided by Lineage 22.2. In an ideal world I should use Lineage 21 so everything matches but that doesn't exist, which is probably half the reason nobody's really tried to do a LOS based SFOS port for the 10 iv yet. |
| 13:54:48 | *&lt;sharks&gt;*: So I either have to port Lineage 21 (which I do not have the time and patience to do) or bodge my way around this somehow I guess |
| 13:55:34 | *&lt;sharks&gt;*: Anyway it's midnight, I will pick this up again later... thanks again for your help everyone |
| 14:21:27 | **&lt;elros34&gt;**: maybe I am missing something  but if lineage 22 works with whatever firmware, blobs and so on from older release then don't change that. It's common that device use latest lineage with some outdated components. |
| 14:23:37 | **&lt;elros34&gt;**: so far you didn't have any serious issue so I am not sure what lneage-21 supposed to fix |

---
### 📅 2026-07-05

| Time | User & Message |
| :--- | :--- |
| 09:19:59 | *&lt;sharks&gt;*: I extracted the rootfs for two identical builds but one with `%define android_version_major 14` and one `15`. I am 100% certain on the device the version 14 one has working VoLTE and version 15 one has broken VoLTE. The base is Lineage 22.2 so it stands to reason I should have A15 set, but comparing the diffs between the rootfs of each I can't see what has changed that should affect VoLTE? Can anyone offer any insight? https://paste.opensu |
| 09:46:38 | **&lt;elros34&gt;**: you could just compare sparse-14 vs sparse-15 |
| 10:04:56 | *&lt;sharks&gt;*: Sure, I could have. I was just trying to be thorough. At any rate, it doesn't change the fact that the only differences are the ApiLevel in gbinder.conf, keymaster vs keymint, /etc/sysconfig/dummy_netd, and a comment in /etc/ofono/ril_subscription.conf. All of these changes I have copied to the phone running the A15 rootfs and I still can't re-enable VoLTE, but if I flash the A14 image it registeres straight away |
| 10:10:58 | **&lt;elros34&gt;**: so maybe it's random issue unrelated to change |

---
### 📅 2026-07-09

| Time | User & Message |
| :--- | :--- |
| 08:12:33 | *&lt;sharks&gt;*: Does anyone know anything about aidl sensors? Logcat is spammed with failures of droid-hal-init / hwservicemanager trying to start various android.hardware.sensors@X.X::ISensors/default, but I have just learnt that sensors are controlled by an aidl interface defined in /vendor/etc/vintf/manifest/android.hardware.sensors-multihal.xml. Not sure how to tackle things from here... |
| 08:18:17 | *&lt;sharks&gt;*: Logcat output -> https://paste.opensuse.org/pastes/509231cc7742 |
| 09:56:28 | *&lt;sharks&gt;*: I am also trying to debug connman(?) I have no cellular data connection available. `connmanctl technologies` only lists ethernet, wifi, bluetooth and gps. |
| 12:56:34 | <mark>&lt;mal&gt;</mark>: sharks: which sailfish version did you build? |
| 21:28:12 | *&lt;Sharks_&gt;*: @mal, I am currently building SFOS 5.1.0.10 on LOS22.2. Please let me know if there's anything I can do to debug sensors and connman and I'll get on it after work today. |

---
### 📅 2026-07-10

| Time | User & Message |
| :--- | :--- |
| 09:54:32 | *&lt;sharks&gt;*: @mal, are you around? I'm deep in the connman / ofono wormhole and frankly over my head, wondering if you (or anyone else) can help at all. |
| 09:54:46 | *&lt;sharks&gt;*: `dbus-send --system --print-reply --dest=org.ofono /ril_0 org.ofono.ConnectionManager.GetProperties` seems okay except "attached" is false. |
| 09:54:48 | *&lt;sharks&gt;*: `dbus-send --system --print-reply --dest=org.ofono /ril_0 org.ofono.ConnectionManager.GetContexts` spits out correct values for internet, MMS and IMS for my carrier |
| 09:54:56 | *&lt;sharks&gt;*: `gdbus call --system --dest org.ofono --object-path / --method org.ofono.Manager.GetModems` says I'm powered, online, got sms, gprs, net, everything seems fine |
| 09:55:00 | *&lt;sharks&gt;*: but `journalctl -b \| grep ofono` comes up completely empty. |
| 09:55:04 | *&lt;sharks&gt;*: I have no idea why it seems like everything is right yet connman can't talk. |
| 09:55:45 | *&lt;sharks&gt;*: As a reminder this is SFOS 5.1 & Lineage 22.2 on Xperia 10 IV |
| 10:17:18 | *&lt;sharks&gt;*: I should probably note that this extends to mms and volte as well. Ofono is working to some extent as SMS works fine, but everything else is not getting configured properly somewhere and I don't know why. I can't test regular calls as I exist in the wrong part of the world for that. I'm VoLTE or nothing. |
| 10:41:15 | *&lt;sharks&gt;*: Output of running connmand manually -> https://paste.opensuse.org/pastes/c4c850f98276 |
| 22:55:21 | <mark>&lt;mal&gt;</mark>: PSA: it's not recommended to use latest droid-hal-device submodule for now, the last change will cause issues on most new device (with a/b slots) unless fstab is patches before building, I'll try to fix that |

---
### 📅 2026-07-11

| Time | User & Message |
| :--- | :--- |
| 00:34:21 | *&lt;sharks&gt;*: @mister_magister did you have any ofono/connman problems with Miami / Lineage22 base? Seems if I set `%define android_version_major` to `14`, I can get VoLTE and MMS, but if I set it to `15` I can't. Either way I can't get cellular internet. |
| 00:34:47 | &lt;Mister_Magister&gt;: no |
| 00:34:52 | &lt;Mister_Magister&gt;: what kind of problems? |
| 00:37:01 | *&lt;sharks&gt;*: I dunno. The output of dbus commands is showing that the SIM card is working fine, it can see all the APNs it needs and everything, but connman is not picking them up. `connmanctl technologies` is completely missing any mention of cellular, `ip a` isn't listing routes. Hardly any mention of ofono at all in journal. But SMS works. |
| 00:37:51 | &lt;Mister_Magister&gt;: idk works for me |
| 00:38:19 | *&lt;sharks&gt;*: Yeah, bugger. It must be a device specific problem I guess |
| 00:40:08 | *&lt;sharks&gt;*: I think I'm going to go back to setting the android version major to 14 again just to make it work, and try to work around any other problems that causes. Might be easier |
| 02:06:48 | <mark>&lt;mal&gt;</mark>: the only relevant difference in droid-hal-config submodule is gbinder api level configuration which is on device at /etc/gbinder.conf |
| 02:07:43 | <mark>&lt;mal&gt;</mark>: you can override that in by adding a working file to sparse/etc/gbinder.conf in your config repo |
| 04:44:37 | *&lt;sharks&gt;*: Changing the gbinder apilevel value from 35 to 30 on device doesn't fix VoLTE. Do I need to do that before the first boot? |
| 04:54:26 | *&lt;sharks&gt;*: Nope, that doesn't work either |
| 09:25:20 | *&lt;sharks&gt;*: Okay - trying to debug sensors now. I learnt that for AIDL sensors I need the latest 0.15.2 version of sensorfw so I compiled that and threw it on the device, which helped progress things along a bit but it's getting stuck with `hw_get_module() probe failed`. Output of running it manually -> https://paste.opensuse.org/pastes/e4e333547bbd |
| 09:26:32 | *&lt;sharks&gt;*: Also strace of what it's looking for --> https://paste.opensuse.org/pastes/644f4a80c5a9, I note that `/vendor/lib64/sensors.ssc.so`, the only sensor.*.so file on my filesystem, is missing from this output. I think that's the problem but I don't know how to fix it. |
| 09:30:53 | **&lt;elros34&gt;**: @sharks what spec file dd you use for building sensorfw plugin? |
| 09:31:29 | *&lt;sharks&gt;*: @elros34 sensorfw-qt5-hybris.spec |
| 09:31:48 | **&lt;elros34&gt;**: that is for old android versions only |
| 09:32:52 | *&lt;sharks&gt;*: ...Really? I was going off what @mal said here: https://piggz.co.uk/sailfishos-porters-archive/index.php?log=2026-04-10.txt#line576 |
| 09:34:38 | **&lt;elros34&gt;**: ok didn't follow this but hw_get_module doesn't seams right |
| 09:35:36 | *&lt;sharks&gt;*: So you suggest trying to build the sensorfw-qt5.spec instead? I can try that I suppose |
| 09:37:20 | **&lt;elros34&gt;**: no, binder one. If your right that link you will see hybris was mistake |
| 09:37:33 | **&lt;elros34&gt;**: read* |
| 09:39:27 | *&lt;sharks&gt;*: Oh balls, you're right. Sorry, I was struggling to follow the conversation too. And now I've already started building the wrong spec file again!! I will wait for it to finish and then build the binder version. Thanks |
| 09:44:45 | *&lt;sharks&gt;*: Wow the binder version builds way quicker |
| 10:17:24 | *&lt;sharks&gt;*: @elros34 didn't seem to go much better with the binder version over the hybris version, I still see the same hw_get_module() probe failed --> https://paste.opensuse.org/pastes/b71ba7f57976 |
| 10:18:20 | *&lt;sharks&gt;*: and it's still not looking for `/vendor/lib64/sensors.ssc.so` --> https://paste.opensuse.org/pastes/fa6010ff3256 |
| 10:18:27 | **&lt;elros34&gt;**: are you sure you have installed the right one? |
| 10:19:04 | *&lt;sharks&gt;*: `rpm -qa` outputs "hybris-libsensorfw-qt5-binder-0.15.2-0.aarch64" |
| 10:20:07 | *&lt;sharks&gt;*: So I have to assume it is the right one |
| 10:20:52 | **&lt;elros34&gt;**: did you git clean -xdf sources when switching from hybris to binder? |
| 10:21:42 | *&lt;sharks&gt;*: Nooooo I just ran `build_packages.sh --mw=https://github.com/sailfishos/sensorfw --spec=rpm/sensorfw-qt5-binder.spec` |
| 10:22:26 | *&lt;sharks&gt;*: If I deleted $ANDROID_ROOT/hybris/mw/sensorfw and started again would that work? |
| 10:23:06 | **&lt;elros34&gt;**: hope so because I have impression you are still using hybris one |
| 10:24:00 | *&lt;sharks&gt;*: So I re-ran the build_packages.sh, changed patterns to have "Requires: hybris-libsensorfw-qt5-binder" instead and built a new image |
| 10:24:15 | **&lt;elros34&gt;**: but how did you choose that specific branch you were talking about? |
| 10:24:23 | *&lt;sharks&gt;*: And confirmed on the new image with `rpm -qa` that the binder version was installed |
| 10:24:42 | *&lt;sharks&gt;*: I didn't choose that specific branch because those changes have since been merged into the master branch |
| 10:25:37 | **&lt;elros34&gt;**: ok |
| 10:26:03 | **&lt;elros34&gt;**: wouldn't be faster to copy rpm and install on device? |
| 10:26:54 | *&lt;sharks&gt;*: Probably but I'm not a smart person and figured the best way of being truly sure some remnant of the old one wasn't still there would be to make a new image |
| 10:27:43 | **&lt;elros34&gt;**: btw I guess binder one is default in patterns. Did you have something else there? |
| 10:28:17 | *&lt;sharks&gt;*: Before in patterns it just had `hybris-libsensorfw-qt5` not `hybris-libsensorfw-qt5-binder` |
| 10:28:48 | **&lt;elros34&gt;**: IIRC same thing |
| 10:28:59 | *&lt;sharks&gt;*: oh |
| 10:29:16 | *&lt;sharks&gt;*: told you I wasn't smart |
| 10:29:45 | *&lt;sharks&gt;*: Okay so delete hybris/mw/sensorfw and build it again to be completely sure it's not still the hybris version? |
| 10:30:17 | **&lt;elros34&gt;**: cmon don't be so hard on you, no way you could know this |
| 10:31:37 | **&lt;elros34&gt;**: yeap delete or clean sources I think there was such a issue long time ago when switchin backend |
| 10:37:48 | *&lt;sharks&gt;*: Yeah okay thanks, I'm trying my best!! Have rebuilt it, copied the new rpm to device, installed with `pkcon install-local hybris-libsensorfw-qt5-binder-0.15.2-0.aarch64.rpm`, and got new output! No longer have "hw_get_module() probe failed" --> https://paste.opensuse.org/pastes/2a6041de7404 |
| 10:38:06 | *&lt;sharks&gt;*: But it still dies: https://paste.opensuse.org/pastes/7e637db5aa62 |
| 10:52:43 | *&lt;sharks&gt;*: Oh logcat is being spammed with "Unable to set property "ctl.interface_start" to "android.hardware.sensors@X.X::ISensors/default..." again, I thought that went away after I installed sensorfw-qt5-hybris but its back now with the binder one. It shouldn't be looking for these at all because they're HIDL not AIDL is my understanding |
| 10:58:56 | **&lt;elros34&gt;**: play with binder-list on /dev/(hw)binder |
| 10:59:40 | **&lt;elros34&gt;**: increasing logs verbosity in sensorfw should also help |
| 11:00:37 | **&lt;elros34&gt;**: you should mask service if you are stating it manually |
| 11:03:52 | *&lt;sharks&gt;*: Alright forgive me but I just went back to check for myself and I definitely don't see those errors if I use the hybris version, but anyway I'll put the binder version back on and "play with binder-list" |
| 11:12:37 | *&lt;sharks&gt;*: Okay `binder-list -d /dev/hwbinder` returns a ton of stuff and `binder-list -d /dev/binder` returns nothing |
| 11:13:20 | *&lt;sharks&gt;*: If it matters the exact output is here --> https://paste.opensuse.org/pastes/254d849e1dfd |
| 11:14:13 | *&lt;sharks&gt;*: But to your point given that I believe the sensors to be AIDL I think you're trying to prove they should show up in the output of the /dev/binder result? |
| 11:17:01 | *&lt;sharks&gt;*: I have also masked sensorfw as requested and run it manually at higher verbosity --> https://paste.opensuse.org/pastes/3698fb982dfa |
| 11:36:47 | <mark>&lt;mal&gt;</mark>: sharks: do you have suitable volte plugin installed? |
| 11:39:41 | *&lt;sharks&gt;*: @mal I reverted android_version_major to 14 and volte registers now, but I have no sound in calls I'm yet to debug that. No matter what I did I could not get volte to register with android_version_major set to 15, even though the only differences I can find should be /etc/gbinder.conf and keymaster vs keymint |
| 11:42:44 | <mark>&lt;mal&gt;</mark>: sharks: another possible reason is that aidl dummy_netd setting in /etc/sysconfig/dummy_netd |
| 11:46:16 | *&lt;sharks&gt;*: You know that's probably totally it, considering its file contents are "DUMMY_NETD_ARGS=--device=/dev/binder" and @elros34 has just helped me prove that /dev/binder is completely empty |
| 11:49:16 | <mark>&lt;mal&gt;</mark>: if binder is empty that mean you have wrong gbinder api level in use |
| 11:49:29 | *&lt;sharks&gt;*: Yep, adding that file to my current working install on device has broken volte registration |
| 11:49:46 | <mark>&lt;mal&gt;</mark>: you should fix gbinder api level |
| 11:49:47 | *&lt;sharks&gt;*: Oh? How do I learn the right gbinder api level? |
| 11:52:34 | <mark>&lt;mal&gt;</mark>: try different value, possible values are https://github.com/mer-hybris/libgbinder/blob/master/src/gbinder_config.c#L189 35 or below, try checking binder-list -d /dev/binder after changing the config value |
| 11:53:00 | *&lt;sharks&gt;*: Do I need to reboot or restart anything first, or just change the value and run `binder-list`? |
| 11:53:07 | <mark>&lt;mal&gt;</mark>: no need to reboot |
| 11:54:25 | *&lt;sharks&gt;*: Dang, I had so much hope |
| 11:54:46 | *&lt;sharks&gt;*: I have tried all of those values, saved the file and run binder-list in between each attempt, but never got any output |
| 11:55:28 | *&lt;sharks&gt;*: Ooh scratch that |
| 11:55:29 | <mark>&lt;mal&gt;</mark>: is servicemanager process running? |
| 11:55:47 | *&lt;sharks&gt;*: Maybe I made a typo, I tried again and with apilevel 35 it works! |
| 11:56:35 | *&lt;sharks&gt;*: I have sensors!!! |
| 11:56:47 | *&lt;sharks&gt;*: mal you are a legend among men |
| 11:56:50 | <mark>&lt;mal&gt;</mark>: so using android_version_major should be fine after you remove that dummy_netd config file |
| 11:57:10 | <mark>&lt;mal&gt;</mark>: *android_version_major 15 |
| 11:57:19 | *&lt;sharks&gt;*: Yes, I will do that, thankyou. |
| 11:57:45 | <mark>&lt;mal&gt;</mark>: removing files can be done with delete_file.list way |
| 11:57:46 | *&lt;sharks&gt;*: Now I just need to fix mobile data because connman does not see a cellular technology for some reason, and fix audio in calls |
| 11:57:51 | <mark>&lt;mal&gt;</mark>: https://github.com/mlehtima/droid-config-fp5 |
| 11:58:05 | <mark>&lt;mal&gt;</mark>: you can see two delete_file*.list files there |
| 11:58:08 | *&lt;sharks&gt;*: I have seen you and magister discuss delete_file.list, I'll do it that way sure thanks |
| 11:58:53 | <mark>&lt;mal&gt;</mark>: to remove that dummy_netd config file you need to use delete_file_$DEVICE.list |
| 11:59:25 | <mark>&lt;mal&gt;</mark>: delete_file.list won't work in that case, has to have the device codename |
| 11:59:49 | *&lt;sharks&gt;*: Sure, thanks I'll do it that way |
| 11:59:55 | *&lt;sharks&gt;*: Not to be greedy but while I've got you, you don't know any leads I could chase to find out why `connmanctl technologies` doesn't list "cellular"? |
| 12:00:17 | *&lt;sharks&gt;*: If you can't help I'm just glad I've got sensors, been fighting that for a week now so thanks again |
| 12:10:13 | *&lt;sharks&gt;*: can confirm delete_file_$device.list worked, VoLTE fixed with android_version_major 15 |
| 12:11:03 | *&lt;sharks&gt;*: And now I've got the latest sensorfw the aidl sensors are working great out of the box |
| 12:11:10 | *&lt;sharks&gt;*: this thing is so close to actually usable now |
| 12:12:55 | <mark>&lt;mal&gt;</mark>: so mobile data is not working? |
| 12:13:08 | *&lt;sharks&gt;*: No, not at all |
| 12:15:19 | <mark>&lt;mal&gt;</mark>: do you see anything from ofono in journal? |
| 12:19:46 | *&lt;sharks&gt;*: ofono related things from journal --> https://paste.opensuse.org/pastes/0f14971b2d31 |
| 12:24:17 | *&lt;sharks&gt;*: I'm no expert but I don't think any of that is to do with mobile data |
| 12:25:13 | *&lt;sharks&gt;*: What I do know is that `dbus-send --system --print-reply --dest=org.ofono /ril_0 org.ofono.ConnectionManager.GetContexts` spits out the right APN for mobile data in "/ril_0/context1" |
| 12:30:04 | <mark>&lt;mal&gt;</mark>: which interface are you using? |
| 12:30:49 | <mark>&lt;mal&gt;</mark>: check binder-list -d /dev/hwbinder for anything related to radio |
| 12:30:58 | *&lt;sharks&gt;*: radioInterface = 1.5 |
| 12:31:05 | <mark>&lt;mal&gt;</mark>: ok |
| 12:31:43 | *&lt;sharks&gt;*: Fair bit of radio stuff in hwbinder --> https://paste.opensuse.org/pastes/08155fbe24b4 |
| 12:34:03 | <mark>&lt;mal&gt;</mark>: try adding defaultDataProfileId = 65535 to /etc/ofono/binder.d/*.conf |
| 12:36:43 | *&lt;sharks&gt;*: Hmm I added it to /etc/ofono/binder.d/qti.conf under [Settings], not sure if that was the right thing to do but after a reboot it has not worked |
| 12:38:49 | <mark>&lt;mal&gt;</mark>: where do you set radioInterface = 1.5? |
| 12:39:36 | <mark>&lt;mal&gt;</mark>: it seems you are not doing that correctly |
| 12:39:44 | <mark>&lt;mal&gt;</mark>: [gbinder-radio] Connected to android.hardware.radio@1.2::IRadio/slot1 |
| 12:39:48 | *&lt;sharks&gt;*: in /etc/binder.d/$device.conf |
| 12:40:01 | <mark>&lt;mal&gt;</mark>: show the file? |
| 12:41:04 | <mark>&lt;mal&gt;</mark>: and that is wrong |
| 12:41:08 | *&lt;sharks&gt;*: repo not up to date with latest changes but https://github.com/sharks-dev/droid-config-pdx225/blob/master/sparse/etc/binder.d/pdx225.conf |
| 12:41:15 | <mark>&lt;mal&gt;</mark>: https://github.com/mer-hybris/droid-config-sony-murray/blob/master/sparse/etc/ofono/binder.d/murray.conf |
| 12:41:28 | *&lt;sharks&gt;*: Dang, I have the location wrong? |
| 12:41:44 | <mark>&lt;mal&gt;</mark>: those should be in /etc/ofono/binder.d/ not /etc/binder.d |
| 12:42:01 | <mark>&lt;mal&gt;</mark>: no wonder you have problems |
| 12:42:25 | *&lt;sharks&gt;*: I believe that's what they call a "rookie mistake" |
| 12:42:41 | *&lt;sharks&gt;*: Thanks for helping mal, I've just fixed that on device and rebooting now |
| 12:44:25 | <mark>&lt;mal&gt;</mark>: I sometimes do such mistakes also |
| 12:44:43 | *&lt;sharks&gt;*: Hmm I may have made a mistake but that hasn't actually fixed it |
| 12:45:46 | *&lt;sharks&gt;*: I moved it to /etc/ofono/binder.d/pdx225.conf but still no mobile data with or without defaultDataProfileId = 65535 |
| 12:46:38 | *&lt;sharks&gt;*: `connmanctl technologies` should list "cellular" shouldn't it, or am I barking up the wrong tree? It still only has ethernet, wifi, bluetooth and gps |
| 12:46:56 | *&lt;sharks&gt;*: And mobile data option in sailfish settings is greyed out and disabled |
| 12:48:16 | <mark>&lt;mal&gt;</mark>: any difference in ofono output |
| 12:49:31 | *&lt;sharks&gt;*: Doesn't seem like much difference --> https://paste.opensuse.org/pastes/8ac498bd9799 |
| 12:57:00 | <mark>&lt;mal&gt;</mark>: hmm, do you have both sim slots enabled? |
| 12:57:35 | *&lt;sharks&gt;*: Yes, is that a bad thing? It's a dual sim phone after all but to be fair I personally only use one sim |
| 12:58:04 | <mark>&lt;mal&gt;</mark>: so what is xperia 10 iv? |
| 12:58:22 | <mark>&lt;mal&gt;</mark>: doesn't it only have one physical sim slot? |
| 12:58:34 | *&lt;sharks&gt;*: No mine is XQ-CC72 |
| 12:58:38 | <mark>&lt;mal&gt;</mark>: ah |
| 12:58:46 | *&lt;sharks&gt;*: I think XQ-CC52 only has one physical sim, but I have two |
| 12:58:57 | <mark>&lt;mal&gt;</mark>: ok, then that is not the problem |
| 12:59:12 | *&lt;sharks&gt;*: Cool, okay |
| 12:59:26 | *&lt;sharks&gt;*: But it could be a problem if someone with a XQ-CC52 tried to use this port? |
| 13:00:57 | <mark>&lt;mal&gt;</mark>: yes |
| 13:01:27 | <mark>&lt;mal&gt;</mark>: at the moment eSIM slots are a problem if there is no valid profile there |
| 13:02:22 | *&lt;sharks&gt;*: So just get rid of /etc/ofono/binder.d/dual-sim.conf and an XQ-CC52 would be happy? Notwithstanding whatever the issue actually is with mobile data? |
| 13:02:42 | <mark>&lt;mal&gt;</mark>: also /etc/ofono/ril_subscription.d/dual-sim.conf |
| 13:02:50 | *&lt;sharks&gt;*: Ah of course |
| 13:04:28 | *&lt;sharks&gt;*: Should there be something in the ofono output that indicates mobile data is working, or are you just looking for some error message? |
| 13:06:19 | <mark>&lt;mal&gt;</mark>: looking for error messages |
| 13:08:26 | *&lt;sharks&gt;*: And it is most likely ofono at fault you think? |
| 13:15:13 | <mark>&lt;mal&gt;</mark>: not sure |
| 13:16:26 | <mark>&lt;mal&gt;</mark>: do you see anything interesting in output of /system/bin/logcat or /system/bin/logcat -b radio |
| 13:18:12 | *&lt;sharks&gt;*: Seems just as devoid as everything else in regards to mobile data --> https://paste.opensuse.org/pastes/13a2cba9d4f8 |
| 13:20:37 | <mark>&lt;mal&gt;</mark>: do you see anything about waiting something in /system/bin/logcat ? |
| 13:22:21 | <mark>&lt;mal&gt;</mark>: did you try removing the dual-sim things already? |
| 13:22:26 | <mark>&lt;mal&gt;</mark>: on device first |
| 13:22:42 | <mark>&lt;mal&gt;</mark>: and don't add the defaultDataProfileId |
| 13:23:14 | *&lt;sharks&gt;*: Not sure this is helping you with anything, but re: waiting... https://paste.opensuse.org/pastes/b9f7c2359a27 |
| 13:23:24 | *&lt;sharks&gt;*: Give me a moment I'll remove dual sim |
| 13:25:32 | <mark>&lt;mal&gt;</mark>: always grep with -i |
| 13:25:53 | *&lt;sharks&gt;*: Oh dual sim did it |
| 13:26:38 | *&lt;sharks&gt;*: Sorry, did not know about `grep -i` |
| 13:26:59 | *&lt;sharks&gt;*: Well I can live with no dual sim, but I wonder why that broke it |
| 13:27:33 | <mark>&lt;mal&gt;</mark>: yes, very odd |
| 13:27:42 | <mark>&lt;mal&gt;</mark>: would need some ofono debug logs probably for that |
| 13:28:28 | <mark>&lt;mal&gt;</mark>: or maybe it didn't like that you had dual sim ofono but not installed jolla-settings-networking-multisim |
| 13:28:43 | <mark>&lt;mal&gt;</mark>: if your patterns are correct |
| 13:29:16 | *&lt;sharks&gt;*: Ah, yes the patterns are correct. That might do it |
| 13:29:46 | <mark>&lt;mal&gt;</mark>: while at it maybe enable some other things, you have nfc disabled, also uncomment that  mapplauncherd-booster-silica-qt5-media |
| 13:30:20 | <mark>&lt;mal&gt;</mark>: in patterns-sailfish-device-configuration-pdx225.inc |
| 13:30:21 | *&lt;sharks&gt;*: I also need to put fingerprint in there too at some stage |
| 13:31:14 | <mark>&lt;mal&gt;</mark>: for nfc to work you need https://github.com/mer-hybris/droid-config-sony-murray/blob/master/sparse/etc/libncicore.conf |
| 13:32:53 | *&lt;sharks&gt;*: Okay sure, thanks mal! |
| 13:33:56 | *&lt;sharks&gt;*: I am glad to have some progress again, it's been a while. You're a lifesaver |
| 13:34:52 | *&lt;sharks&gt;*: If I can fix audio in calls now I will have a device functional enough to put back in my pocket, but it is getting close to midnight again so perhaps I should leave that challenge for another day |

---
### 📅 2026-07-12

| Time | User & Message |
| :--- | :--- |
| 03:54:16 | *&lt;sharks&gt;*: Dang, is it the case that no audio during calls is not a trivial thing? I thought it was a relatively common issue but there doesn't seem to be a relatively common solution? |
| 04:56:43 | *&lt;sharks&gt;*: Also @mister_magister did you solve the not being able to reject a call issue? I have noticed it is happening to me too |
| 07:16:59 | *&lt;sharks&gt;*: From the logs on 2023-04-13 mal, k1gen and edp_17 were all having issues with audio in calls and they suspected because they all used hidl_compat. I am also using hidl-compat. Does anyone know if they ever got to the bottom of this problem? Does fp4 / motog7 / pixel4 still have no audio in calls? |
| 07:27:14 | *&lt;sharks&gt;*: On 2023-07-25 it was mentioned that you need dummy-af if you have vendor.qti.*.am@ in binder-list, but I have both. Do I need audioflinger or something? |
| 09:53:39 | *&lt;sharks_&gt;*: Do I need the jb2q audio even though I have Android 15? |
| 11:51:07 | <mark>&lt;mal&gt;</mark>: no, you don't use jb2q, and you should have dummy-af |
| 12:45:45 | &lt;T42&gt;: <Mister_Magister> yes i did solve it (re @SailfishFreenodeIRCBridgeBot: <sharks>Also @mister...) |
| 12:46:02 | &lt;T42&gt;: <Mister_Magister> but unless you have motorola with similar vendor it mostlikely won't help you |
| 12:52:50 | <mark>&lt;mal&gt;</mark>: sharks: call audio is usually just about getting the hidl_compat module to function properly |
| 23:34:23 | *&lt;Sharks_&gt;*: Forgive me if I'm slack at replying, currently on morning tea break at work, but I can't see any apparent fault in `/system/bin/logcat -b all \| grep -iE "voice\|pcm\|voip\|incall\|start_voice\|s |
| 23:34:23 | *&lt;Sharks_&gt;*: top_voice"` when making a call. Am I looking in the wrong spot? https://paste.opensuse.org/pastes/e9201fda5d52 |
| 23:36:13 | <mark>&lt;mal&gt;</mark>: Sharks_: you are using sailfish 5.1? |
| 23:36:43 | <mark>&lt;mal&gt;</mark>: which pulseaudio-modules-droid version do you have? and droid-config submodule revision? |
| 23:40:29 | *&lt;Sharks_&gt;*: 5.1.0.10 at the minute, yes. I have 'pulseaudio-modules-droid-common-14.2.109-1.aarch64', 'pulseaudio-modules-droid-14.2.109-1.aarch64', 'pulseaudio-modules-droid-hidl-1.5.1-1.aarch64'. Droid-configs-device is @41cd1d9 |
| 23:45:56 | <mark>&lt;mal&gt;</mark>: too new pulseaudio-modules-droid, you should build 14.2.106 (commit 65edd31f62f22e2eec1f765608ca9c6ae5c4af7b) |
| 23:46:48 | <mark>&lt;mal&gt;</mark>: when building next image use 5.1.0.11, that is the latest 5.1 release |
| 23:50:50 | *&lt;Sharks_&gt;*: thankyou mal, when I get home from work I will try that. Really appreciate it, I was quite lost trying to work out where I had gone wrong. |
| 23:51:32 | <mark>&lt;mal&gt;</mark>: Sharks_: when building pulseaudio-modules-droid, either use "build_packages.sh -b hybris/mw/libhybris" or use build_packages -o --mw (that -o means offline mode i.e. it won't update to latest commit before building) |
| 23:52:39 | <mark>&lt;mal&gt;</mark>: Sharks_: yes, it's a bit problematic when latest package versions won't work with latest public sailfish release, it happens sometimes |
| 23:53:27 | *&lt;Sharks_&gt;*: Understood, I'll delete the rpms in droid-local-repo, clone the correct version and build the offline mode. I was also planning on upgrading to 5.1.0.11 once I had the bugs ironed out |
| 23:54:12 | <mark>&lt;mal&gt;</mark>: I'll go offline now, it'a already 3 am here |
| 23:55:24 | *&lt;Sharks_&gt;*: Goodness, I thought two nights ago it was bad that I was still debugging at 1:30AM |
| 23:55:47 | *&lt;Sharks_&gt;*: Thanks again, I'll let you know how I get on this evening |

---
### 📅 2026-07-13

| Time | User & Message |
| :--- | :--- |
| 07:06:43 | *&lt;sharks&gt;*: OH YEAH! I downgraded pulseaudio-modules-droid to 14.2.106 and pulseaudio woudn't start, "Failed to parse module arguments". My old arguments were `rate=48000 hw_volume=false use_legacy_stream_set_parameters=true`. I removed the legacy_stream_set_parameters argument and we've got audio in calls!!! The Xperia 10 IV is a working phone again! |
| 07:07:12 | *&lt;sharks&gt;*: Thankyou again mal, I've said it before but you're a legend among men |
| 07:29:19 | *&lt;sharks&gt;*: Okay now things are getting scary, I have a basically fully functioning port so I would like to get jolla store access etc... but reading hadk-faq I need to get OBS first? however I don't know what I am doing fully, and some things eg. sledges name, links for https://webhook.merproject.org/webhook are out of date, so not sure if the guide is fully reliable. Anyone willing to walk me through it? |
| 07:32:06 | **&lt;elros34&gt;**: more info about obs in hadk-hot -< that one which nobody is reading |
| 07:34:21 | *&lt;sharks&gt;*: Thanks elros, I'll read up on what I can see there. Either way seems like first step is to contact @Keto so hopefully they spot this sometime |
| 07:35:45 | **&lt;elros34&gt;**: yeah you need account first |
| 07:37:32 | *&lt;sharks&gt;*: Not really worth releasing my port to the public without jolla store so yeah I'll have to work out how to set that up |
| 07:40:43 | &lt;adampigg&gt;: simple, you ping keto with some config (re @SailfishFreenodeIRCBridgeBot: <sharks>Not really w...) |
| 07:42:16 | *&lt;sharks&gt;*: @adampigg is this for jolla store or for OBS? I need to give keto the output of `ssu s` for jolla store but not before I've got OBS according to hadk-faq |
| 07:42:32 | &lt;adampigg&gt;: ah ok |
| 07:43:57 | *&lt;sharks&gt;*: So I guess I just have to wait until it's a reasonable hour of the day in Sweden |
| 08:11:56 | *&lt;sharks&gt;*: Does anyone have an official Xperia 10 IV in their drawer at the minute? What are the chances the output of `ssu s` is the same and I've already got jolla store access? haha |
| 09:21:00 | &lt;Keto&gt;: xqcc54? |
| 09:22:59 | *&lt;sharks&gt;*: Hey - `ssu s` spits out "Device model: Xperia 10 IV (pdx225 / pdx225)" on my build. My phone in particular is XQ-CC72 but I presume it will work on XQ-CC52 as well |
| 09:23:14 | *&lt;sharks&gt;*: I think 54 is 10V |
| 09:23:18 | *&lt;sharks&gt;*: I have not ported that |
| 09:29:33 | &lt;Keto&gt;: that pdx225 is probably slightly wrong value to use for the model/variant... but I'm not sure |
| 09:30:21 | *&lt;sharks&gt;*: Drat, I wouldn't know how to change it now! It's worked up until now! |
| 09:30:41 | *&lt;sharks&gt;*: It's the value all the LineageOS people used so I assumed I could use it too |
| 09:36:42 | *&lt;sharks&gt;*: So do I need to come back another day after I've worked out how to change that value to XQ-CC72? |
| 09:36:50 | &lt;Keto&gt;: afaik pdx225 is common X10IV platform, but then there are different xqcc* variants, which may require slighlty different configuration |
| 09:38:38 | &lt;Keto&gt;: the official Jolla images are for xqcc54 |
| 09:38:51 | *&lt;sharks&gt;*: Hmm, I used Jolla official SFOS for 1.5yrs which was "supposed" to be for XQ-CC54, and it never had any problem. And as I say the Lineage people refer to the both of them as pdx225 and offer identical images for either 54 or 72. |
| 09:39:03 | *&lt;sharks&gt;*: It appears I was wrong, it is 54 not 52 but points still stand |
| 09:40:06 | *&lt;sharks&gt;*: See eg. https://wiki.lineageos.org/devices/pdx225/install/ |
| 09:41:02 | &lt;Keto&gt;: yeah, it probably works, I don't know what are the differences in those variants. but we just haven't had 72 device to test it |
| 09:42:28 | *&lt;sharks&gt;*: The difference AFAIK is esim vs. second physical sim, but otherwise identical. But as I say I've used your image on a 72 device for a long time and have observed no apparent differences between that and a 54 device |
| 09:45:50 | *&lt;sharks&gt;*: Anyway if you want me to go back and change it to XQ-CC72 I guess I can work out how to do that and come back again another day? |
| 09:48:38 | *&lt;sharks&gt;*: I also wondered if it should be "murray" instead of "pdx225" but as I say, I have used pdx225 the whole time. Also fixup-mountpoints already used pdx225 which was another reason I was relatively confident that was a reasonable decision |
| 09:49:53 | &lt;Keto&gt;: yes, that probably would be better. also we might need to think a bit how we name and identify these when there is a "official" and "community" port for the same device |
| 09:50:39 | *&lt;sharks&gt;*: Sorry - what would be better? murray or XQ-CC72? |
| 09:50:53 | &lt;Keto&gt;: xqcc72 |
| 09:51:20 | *&lt;sharks&gt;*: Okay, and people who have a 54 will hopefully not be affected |
| 09:51:38 | &lt;Keto&gt;: yes |
| 09:51:45 | *&lt;sharks&gt;*: I will try and work out how to change it tonight I guess and ping you again tomorrow |
| 09:52:29 | *&lt;sharks&gt;*: I agree we need some distinction between this and the official port, to be honest I thought Jolla might have a plan seeing as they have floated the idea of a community port a few times! But happy to work with you there. |
| 09:56:08 | &lt;Keto&gt;: unfortunately can't help you more right now, as I don't remember/know all the details |
| 09:56:47 | *&lt;sharks&gt;*: No worries, as I say I'll try to figure out what I can in the next hour or two and ping you same time tomorrow if that works |
| 09:58:10 | *&lt;sharks&gt;*: Worst case I start all over again with xqcc72 instead of pdx225 and just make all the same changes I guess! |
| 10:21:07 | *&lt;sharks&gt;*: Oh no I have to rebuild everything and I'm failing on the first hurdle |
| 10:21:35 | *&lt;sharks&gt;*: `breakfast $DEVICE` doesn't work when Android thinks the device is pdx225 but sailfish wants xqcc72 |
| 10:22:39 | *&lt;sharks&gt;*: I'm not entirely convinced this is a good idea |
| 10:26:16 | &lt;BigChadCat&gt;: Couldn't you do something with init that sets the value to xqcc72 on runtime and let the codename remain pdx225 |
| 10:27:07 | *&lt;sharks&gt;*: Is that an option? I'm just a guy sitting in front of a keyboard. @Keto or @mal can you please weigh in on this? |
| 10:29:33 | &lt;BigChadCat&gt;: I mean I'm more of an AOSP engineer and not SF, but we do this quite a lot of times |
| 10:30:58 | *&lt;sharks&gt;*: Oh? Do you have an example I can look at in a device repo somewhere? |
| 10:31:25 | &lt;BigChadCat&gt;: github.com/xiaomi-sm6150 |
| 10:31:25 | &lt;BigChadCat&gt;:  |
| 10:31:26 | &lt;BigChadCat&gt;: You just want to change a property, right? |
| 10:31:29 | &lt;BigChadCat&gt;: Where is that property read from? |
| 10:32:06 | &lt;BigChadCat&gt;: https://github.com/xiaomi-sm6150/android_device_xiaomi_phoenix/blob/lineage-23.2/init/init_phoenix.cpp |
| 10:32:10 | &lt;BigChadCat&gt;: this is what I meant |
| 10:32:40 | &lt;BigChadCat&gt;: It runs on boot, and it detects a property to differentiate between global and CN variant of the device, and depending on that, sets SKU props |
| 10:33:47 | *&lt;sharks&gt;*: I don't know enough about Sailfish to know if I can do that |
| 10:34:26 | *&lt;sharks&gt;*: I would love it if I could |
| 10:35:08 | &lt;BigChadCat&gt;: same tbh, but it's worth a thought |
| 10:35:25 | &lt;BigChadCat&gt;: wish they sold these devices in IN |
| 10:35:27 | <mark>&lt;mal&gt;</mark>: sharks: HABUILD_DEVICE env var |
| 10:38:49 | *&lt;sharks&gt;*: Sorry mal, can you elaborate? I do not have that env var set in platformsdk or habuild. Do I set it in both, then run `breakfast $HABUILD_DEVICE`, then `make hybris-hal droidmedia etc` and it will output these to "./out/target/product/$DEVICE/" rather than "./out/target/product/$HABUILD_DEVICE/" so the `build_packages.sh` scripts are happy? |
| 10:39:13 | *&lt;sharks&gt;*: I just don't want to sit here for two hours while hybris-hal builds if that's not going to work |
| 10:40:22 | <mark>&lt;mal&gt;</mark>: make hybris-hal will output to whatever android think it wants to do, the HABUILD_DEVICE is for packaging part |
| 10:40:50 | <mark>&lt;mal&gt;</mark>: i.e. build_packages.sh to find things correctly |
| 10:41:41 | *&lt;sharks&gt;*: so I ran `export HABUILD_DEVICE=pdx225` then `rpm/dhd/helpers/build_packages.sh --droid-hal`, and it fails because "Can't open ./out/target/product/xqcc72/obj/KERNEL_OBJ/.config: No such file or directory" |
| 10:42:02 | *&lt;sharks&gt;*: because it's in "./out/target/product/pdx225/..." |
| 10:42:24 | *&lt;sharks&gt;*: I could maybe just rename the directory but surely that will break something else |
| 10:42:57 | <mark>&lt;mal&gt;</mark>: export DEVICE=xqcc54 |
| 10:42:58 | <mark>&lt;mal&gt;</mark>: export HABUILD_DEVICE=pdx225 |
| 10:43:06 | <mark>&lt;mal&gt;</mark>: I use those in my builds |
| 10:43:57 | *&lt;sharks&gt;*: I hate to say it but that is 100% not working here |
| 10:50:48 | *&lt;sharks&gt;*: Oh that's why |
| 10:51:10 | *&lt;sharks&gt;*: rpm/droid-hal-xqcc72.spec should be rpm/droid-hal-pdx225.spec still |
| 10:51:14 | *&lt;sharks&gt;*: this is going to get messy |
| 10:52:42 | <mark>&lt;mal&gt;</mark>: yeah, if I remember correctly sony people said same image could be used with xqcc54 and xqcc72 |
| 10:53:20 | *&lt;sharks&gt;*: Yeah I can confirm that firsthand like I said |
| 10:53:45 | *&lt;sharks&gt;*: Changing the spec filename didn't fix it, I guess there's a lot more things like that where I don't know if I should be using $DEVICE or $HABUILD_DEVICE |
| 10:57:23 | *&lt;sharks&gt;*: Why does `build_packages.sh --droid-hal` verify the kernel config, and where does it get the idea that the kernel config is at "./out/target/product/$DEVICE/..."? |
| 11:03:23 | *&lt;sharks&gt;*: right, "%define device" in rpm/droid-hal-pdx225.spec has to still also be pdx225, not xqcc72 |
| 11:04:17 | *&lt;sharks&gt;*: woo, built dhd, let's see if I can keep going |
| 11:09:21 | *&lt;sharks&gt;*: dang, stuck again at mw, "No provider of 'droid-hal-xqcc72-devel' found." |
| 11:09:29 | *&lt;sharks&gt;*: time to grep logs |
| 11:10:20 | *&lt;sharks&gt;*: oh is it because I made a new target? |
| 11:11:54 | *&lt;sharks&gt;*: yeah totally is, okay gotta run build_packages with no params first i guess |
| 11:14:06 | *&lt;sharks&gt;*: hmm even then I still get it |
| 11:30:57 | *&lt;sharks&gt;*: Ah, droid-configs/rpm/droid-config-xqcc72.spec is still supposed to have device pdx225 but also rpm_device xqcc54 |
| 11:31:18 | *&lt;sharks&gt;*: or xqcc72 rather |
| 11:34:15 | *&lt;sharks&gt;*: similar story for droid-hal-version |
| 11:36:08 | *&lt;sharks&gt;*: no that didn't fix it |
| 11:36:51 | *&lt;sharks&gt;*: why is it looking for droid-hal-xqcc72-devel? I have in droid-local-repo droid-hal-pdx225-devel |
| 11:38:47 | *&lt;sharks&gt;*: oh there's a FAMILY variable |
| 11:40:04 | *&lt;sharks&gt;*: Great, `export FAMILY=pdx225` did it |
| 11:45:19 | <mark>&lt;mal&gt;</mark>: sharks: patterns need to be adjusted for the new spec naming |
| 11:45:54 | *&lt;sharks&gt;*: That one I've worked out ahead of time, yet to be seen if I have done it right though |
| 11:46:03 | *&lt;sharks&gt;*: building the mic now so should know shortly |
| 11:46:47 | *&lt;sharks&gt;*: Ah crap I forgot parse-android-dynparts and things |
| 11:46:55 | *&lt;sharks&gt;*: should have read my own notes |
| 11:56:53 | *&lt;sharks&gt;*: heh, there goes the phone. Nearly time to flash and see if it works |
| 12:04:55 | *&lt;sharks&gt;*: well it booted |
| 12:05:56 | *&lt;sharks&gt;*: seems to work |
| 12:06:33 | *&lt;sharks&gt;*: `ssu s` now says "Device model: Xperia 10 IV (xqcc72 / xqcc72)" |
| 12:06:58 | *&lt;sharks&gt;*: So I think I was successful |
| 12:08:50 | *&lt;sharks&gt;*: I will commit changes and go to bed. @Keto are you around sometime in the morning UTC tomorrow to talk about OBS things? |
| 12:10:18 | &lt;Keto&gt;: what kind of OBS things? |
| 12:11:39 | *&lt;sharks&gt;*: I am following hadk-faq & hadk-hot, it says in order to have jolla store access I should have OBS set up, and in order to do that I need an account, which I need to ping you about |
| 12:13:01 | &lt;Keto&gt;: ok |
| 12:13:16 | *&lt;sharks&gt;*: Thanks |

---
### 📅 2026-07-14

| Time | User & Message |
| :--- | :--- |
| 05:54:28 | *&lt;sharks&gt;*: @mal may I pretty please have a project set up for me on OBS? Do we need to discuss how to differentiate between the Jolla port and the Community port? |
| 06:24:06 | &lt;rinigus&gt;: Keto: ^ please help with OBS account |
| 06:24:35 | *&lt;sharks&gt;*: Thanks rinigus, I have the account as of last night but I need the project |
| 06:26:03 | &lt;rinigus&gt;: great :) |
| 06:27:09 | *&lt;sharks&gt;*: I thought so! I'm keen to get it set up properly. |
| 07:27:08 | *&lt;sharks&gt;*: @Keto did you already give me store access? I was surprised to login just now and find it working? |
| 07:34:22 | **&lt;elros34&gt;**: working or you see literally just few applications? |
| 07:34:52 | &lt;Keto&gt;: it's not so much about the access, but adding the device info so that it knows which apps to show |
| 07:35:27 | *&lt;sharks&gt;*: Ah, understood |
| 07:35:36 | *&lt;sharks&gt;*: I had never bothered to try it until now to be honest |
| 07:35:37 | &lt;Keto&gt;: and no, I didn't do that yet... so it probabably shows just the noarch apps |
| 07:36:08 | *&lt;sharks&gt;*: Are you the right person to ask about getting the OBS project or only the OBS account? |
| 07:41:07 | &lt;Keto&gt;: I could create the project, but I'm not sure what it should be called... |
| 07:41:31 | *&lt;sharks&gt;*: Right, so how do we decide that? |
| 07:43:03 | &lt;Keto&gt;: mal can probably help with that |
| 07:43:05 | *&lt;sharks&gt;*: Given that 1 IV and 5 IV are nemo:devel:hw:sony:nagara, should this be nemo:devel:hw:sony:murray? |
| 07:43:55 | &lt;adampigg&gt;: sharks: it should match what you have in $DEVICE in your config repo |
| 07:44:06 | &lt;adampigg&gt;: but murray sounds ok to me |
| 07:44:26 | *&lt;sharks&gt;*: @adampigg that is xqcc72 but Keto is worried it will get confused with the official X10IV port |
| 07:44:46 | *&lt;sharks&gt;*: Which is a reasonable concern |
| 07:46:15 | &lt;adampigg&gt;: just change your $DEVICE then |
| 07:46:31 | *&lt;sharks&gt;*: I just did that 24 hrs ago!! |
| 07:47:00 | *&lt;sharks&gt;*: It used to be pdx225 but I was asked to change it to xqcc72 |
| 07:48:57 | **&lt;elros34&gt;**: so maybe xqcc72_lineage pdx225_lineage |
| 07:51:54 | *&lt;sharks&gt;*: I dunno, I like murray so long as Jolla aren't using that term internally, but I guess it's up to mal by the sounds of it |
| 07:55:45 | *&lt;sharks&gt;*: Oh maybe they are using murray because their repo is github.com/mer-hybris/droid-config-sony-murray |
| 08:36:09 | &lt;rinigus&gt;: sharks: I would suggest murray. similar to tama and nagara. and it doesn't matter what Jolla is using in official port, they are not on OBS. |
| 08:36:50 | *&lt;sharks&gt;*: I agree rinigus, I just need mal and/or keto to pull the trigger for me. |
| 08:38:57 | &lt;rinigus&gt;: xqcc72 sounds reasonable for device names. later you can add other variants. see nagara on how to jiggle with multiple variants. we have slightly modified repos to make sure that correct OBS URLs are pulled and so on. but its all relatively simple to manage if you study our github project a bit. |
| 08:41:15 | *&lt;Sharks_&gt;*: Thanks, I have been using your github as guidance a bit. I have never used OBS before, so that's the next learning curve. After that if I need to I'll start juggling variants. |
| 11:28:25 | <mark>&lt;mal&gt;</mark>: sharks: need to think about name a bit, in internal project we use all of the murray, pdx225 and xqcc54 in various parts of the repos |
| 11:30:12 | *&lt;Sharks_&gt;*: Hey mal, thanks for getting back to me - I'm about to go to bed, but I'd appreciate it if you can have a think about it today and let me know what you dream up. |
| 11:32:22 | *&lt;Sharks_&gt;*: Like rinigus said, does it matter what name Jolla uses given official ports don't use OBS? |
| 23:24:13 | *&lt;Sharks_&gt;*: Apologies @mal, I don't mean to be pushy but have you had the chance to think about what to name my port? I'm keen to get it in the hands of more people but am hesitant to do that without it having its own repository. Maybe I shouldn't be? Happy to take advice in that regard. |

---
### 📅 2026-07-15

| Time | User & Message |
| :--- | :--- |
| 07:40:30 | *&lt;sharks&gt;*: @rinigus Do you know what would be required to tailor droid-bthelper to android.hardware.audio@6.0? I am seeing "setConnectedState transact failed for AUDIO_DEVICE_OUT_BLUETOOTH_SCO_HEADSET" and "Failed to set status to disconnected through AudioHal for 68:D6:ED:F1:D2:3B". |
| 07:56:15 | &lt;rinigus&gt;: sharks: you should get OBS repos (devel and testing) for the port before releasing it. that would later simplify life for all users |
| 07:57:12 | &lt;rinigus&gt;: sharks: its a while since I worked on droid-bthelper, sorry. you would have to look into it yourself |
| 07:57:28 | *&lt;sharks&gt;*: Cool, thanks. I'm really hoping @mal has thought up a name for me and I can get my very own repo this evening. |
| 07:58:06 | *&lt;sharks&gt;*: No worries, it was a long shot but I thought it was worth asking in case it saved me a few hours. I'll continue digging into it myself. Thanks for giving me a starting point though! |
| 07:58:11 | &lt;rinigus&gt;: btw, to distinguish, you could also opt for murray-los . in principle, it shouldn't matter |
| 07:58:26 | *&lt;sharks&gt;*: murray-los would be more than fine by me |
| 07:58:59 | &lt;rinigus&gt;: however, it would be somewhat inconsistent as nagara is also los based |
| 07:59:01 | &lt;rinigus&gt;: :) |
| 07:59:54 | *&lt;sharks&gt;*: True, but nagara doesn't have an active SODP port running in parallel anymore! |
| 08:00:12 | *&lt;sharks&gt;*: So it doesn't require the distinction |
| 09:10:07 | *&lt;sharks&gt;*: @mal or @Keto can I pretty please with a cherry on top have a repo made for me? I would really love to get something done tonight as 2026-07-15T10:14:21  <mal> sharks: what is you obs username? |
| 10:14:27 | *&lt;sharks&gt;*: sharks |
| 10:18:19 | *&lt;sharks&gt;*: Thankyou mal!! |
| 10:19:25 | <mark>&lt;mal&gt;</mark>: https://build.sailfishos.org/project/show/nemo:devel:hw:sony:murray and https://build.sailfishos.org/project/show/nemo:testing:hw:sony:murray |
| 10:21:09 | *&lt;sharks&gt;*: Very appreciated, thanks so much. I will populate them according to hadk and add them to my image so I can get the port out. Thankyou thankyou thankyou! |
| 10:47:20 | <mark>&lt;mal&gt;</mark>: sharks: you probably should make lvm based image before releasing it |
| 10:47:38 | *&lt;sharks&gt;*: Bugger. Where do I find documentation on that process? |
| 10:51:25 | <mark>&lt;mal&gt;</mark>: there isn't any but it's pretty much just copying this folder and all its content and adjusting the needed parts https://github.com/mer-hybris/droid-config-sony-murray/tree/master/kickstart |
| 10:52:22 | *&lt;sharks&gt;*: Okay, then just build and flash as normal? What's the catch? |
| 10:52:29 | <mark>&lt;mal&gt;</mark>: adjusting the file names and codenames in the files |
| 10:52:37 | *&lt;sharks&gt;*: Sounds too easy |
| 10:52:39 | <mark>&lt;mal&gt;</mark>: also you need to build new boot images |
| 10:53:04 | *&lt;sharks&gt;*: Oh bugger, there's the catch. |
| 10:53:24 | *&lt;sharks&gt;*: Okay, I better get the ball rolling on that then, gonna take 2hrs to build that and I'll be in bed by then! |
| 10:54:18 | <mark>&lt;mal&gt;</mark>: what? |
| 10:54:41 | <mark>&lt;mal&gt;</mark>: that are you going to build that takes so long? |
| 10:55:17 | <mark>&lt;mal&gt;</mark>: the lvm based boot images are completely separate from the others and the build of those happens on obs |
| 10:56:50 | <mark>&lt;mal&gt;</mark>: something like this https://github.com/mer-hybris/droid-hal-img-boot-sony-murray |
| 10:56:58 | *&lt;sharks&gt;*: Oh sorry, I misunderstood. I thought I had to jump back into the habuild environment on my local machine |
| 10:57:30 | <mark>&lt;mal&gt;</mark>: you need to adjust boot image generation commands to match your build |
| 10:57:37 | <mark>&lt;mal&gt;</mark>: in the spec of that |
| 10:58:21 | <mark>&lt;mal&gt;</mark>: maybe increate lvm_root_size also, we have been using 10000 on newer devices, can't remember how big internal storage x10iv had |
| 10:58:21 | *&lt;sharks&gt;*: Right, this is going to take a bit to wrap my head around. Thanks mal, I'll see how I go |
| 10:58:39 | <mark>&lt;mal&gt;</mark>: also you need to adjust patterns |
| 10:59:30 | *&lt;sharks&gt;*: 128gb is internal storage |
| 10:59:44 | *&lt;sharks&gt;*: I saw that the obs patterns were different, I need to understand how to change that too |
| 11:00:18 | <mark>&lt;mal&gt;</mark>: also while at it add proper .gitignore to your config repo https://github.com/sailfishos-sony-nagara/droid-config-sony-nagara/blob/main/.gitignore  like that and remove the useless installroot, tmp and documentation.list from your droid-config repo |
| 11:00:54 | *&lt;sharks&gt;*: will do, sure. Thanks |
| 11:01:02 | <mark>&lt;mal&gt;</mark>: for patterns you need to remove Requires: droid-hal-pdx225-kernel-modules |
| 11:01:38 | <mark>&lt;mal&gt;</mark>: also you are missing Requires: droid-hal-pdx225-vendor_boot and Requires: droid-hal-pdx225-kernel-dtbo |
| 11:02:07 | *&lt;sharks&gt;*: What do they do, and why does my phone work perfectly fine without them? |
| 11:02:41 | *&lt;sharks&gt;*: I don't mean to be rude I'm just trying to learn |
| 11:02:41 | <mark>&lt;mal&gt;</mark>: the droid-hal-pdx225-kernel-modules is needed when using community style boot image, lvm based boot image contains those |
| 11:02:51 | *&lt;sharks&gt;*: Right, okay sure |
| 11:03:06 | <mark>&lt;mal&gt;</mark>: and you probably just flashed manually vendor_boot and dtbo |
| 11:03:32 | <mark>&lt;mal&gt;</mark>: the packages are needed if you want to be able to update kernel and dtbo from obs |
| 11:03:39 | *&lt;sharks&gt;*: Never vendor_boot, I flashed vbmeta and dtbo from Lineage |
| 11:03:50 | <mark>&lt;mal&gt;</mark>: hmm |
| 11:04:11 | <mark>&lt;mal&gt;</mark>: can't remember if vendor_boot had anything useful on x10iv, maybe it didn't |
| 11:04:58 | *&lt;sharks&gt;*: Lineage do have a download for vendor_boot but their instructions don't call for it to be flashed so I never did |
| 11:05:37 | <mark>&lt;mal&gt;</mark>: ok |
| 11:05:42 | <mark>&lt;mal&gt;</mark>: maybe you can skip it then |
| 11:06:02 | *&lt;sharks&gt;*: Okay, I'll try that |
| 11:07:15 | <mark>&lt;mal&gt;</mark>: another thing is that you should add file /usr/share/ssu/board-mappings.d/10-community.in with this content: |
| 11:07:28 | <mark>&lt;mal&gt;</mark>: [xqcc72] |
| 11:07:35 | <mark>&lt;mal&gt;</mark>: deviceDesignation=community |
| 11:07:57 | <mark>&lt;mal&gt;</mark>: that goes to droid-config sparse as usual |
| 11:08:03 | &lt;Keto&gt;: .ini |
| 11:08:09 | <mark>&lt;mal&gt;</mark>: oops |
| 11:08:23 | <mark>&lt;mal&gt;</mark>: so that goes to /usr/share/ssu/board-mappings.d/10-community.ini |
| 11:08:29 | <mark>&lt;mal&gt;</mark>: copy paste mistake earlier |
| 11:08:56 | *&lt;sharks&gt;*: Okay, no worries. |
| 11:12:05 | &lt;Keto&gt;: that'll set the second value shown in parentheses on the ssu device model line, and we can use that to distinguish the different ports on the store side |
| 11:14:22 | *&lt;sharks&gt;*: Fantastic, I'll make sure that happens then. mal - any particular submodule revision for droid-hal-img-boot-$VENDOR-$DEVICE? same as the one you've got in murray? |
| 11:18:55 | <mark>&lt;mal&gt;</mark>: you can use latest submodule |
| 11:19:09 | *&lt;sharks&gt;*: Thanks |
| 11:37:57 | *&lt;sharks&gt;*: Right, I think I've done all those things. I have work early in the morning so I need to head to bed soon, so I guess I will not get to start playing with OBS properly until Friday night. But hopefully I'm a little bit closer. Thanks again |

---
### 📅 2026-07-17

| Time | User & Message |
| :--- | :--- |
| 08:04:09 | *&lt;sharks&gt;*: Can someone idiot-check why my OBS packages are failing to build with `nothing provides pkconfig(android-headers)`, `nothing provides pkconfig(libgbinder)` etc.? Reading irc logs people say wrong arch etc. but I can't see where I've got anything but aarch64 in there. |
| 08:06:48 | &lt;rinigus&gt;: sharks: look into droid-hal config of nagara. you need to "build" it - use similar approach as used there |
| 08:07:45 | &lt;rinigus&gt;: sharks: add build.script to it |
| 08:08:08 | *&lt;sharks&gt;*: Ohh - I am indeed missing build.script. Thankyou! |
| 08:12:57 | *&lt;sharks&gt;*: Hmm, droid-hal-$device now has build.script in it but OBS says it's "excluded" - am I missing any other step? Sorry to be a pain, I'm new to this. |
| 08:17:43 | &lt;rinigus&gt;: sharks: this one too - https://build.sailfishos.org/package/view_file/nemo:devel:hw:sony:nagara/droid-hal-nagara/droid-hal.spec |
| 08:19:28 | *&lt;sharks&gt;*: Oh God, sorry. I think I need more sleep, didn't realise there was two pages and that file was on the second page!! Thanks rinigus. |
| 09:27:22 | *&lt;sharks&gt;*: Okay, stuck again - does anyone know why I've got this one now? Not sure what I've done differently to droid-hal-img-boot-fp5 that would cause this... |
| 09:27:24 | *&lt;sharks&gt;*: RPM build errors: |
| 09:27:24 | *&lt;sharks&gt;*: Could not canonicalize hostname: phost18 |
| 09:27:24 | *&lt;sharks&gt;*: Bad exit status from /var/tmp/rpm-tmp.WMIfot (%build) |
| 09:27:24 | *&lt;sharks&gt;*: phost18 failed "build droid-hal-pdx225-img-boot.spec" at Fri Jul 17 09:25:13 UTC 2026. |
| 09:30:09 | &lt;rinigus&gt;: sharks: error is a bit above it - /usr/bin/env: 'python3' |
| 09:30:20 | &lt;rinigus&gt;: looks like python dependency is missing in spec |
| 09:33:19 | *&lt;sharks&gt;*: Hmm, in fp5 the python dependency is in droid-hal-device-img-boot.inc, but by the time I cloned that submodule two years later it was taken out. |
| 09:34:57 | *&lt;sharks&gt;*: Not sure why that would be the case, but thanks anyway rinigus - I'll work around it... |
| 10:15:38 | *&lt;sharks&gt;*: Perhaps another silly question - where do the repo URLs in droid-config-xqcc72-ssu-kickstarts.aarch64.rpm come from? They're assuming my repo is at nemo:testing:hw:sony:xqcc72 not nemo:devel:hw:sony:murray |
| 10:48:03 | *&lt;sharks&gt;*: I'm completely stumped as to how to fix that, I can't see at all how it's supposed to be configured. |
| 10:53:29 | &lt;rinigus&gt;: sharks: that is not that silly question. if I remember correctly you need to add https://build.sailfishos.org/package/show/nemo:devel:hw:sony:nagara/community-adaptation-devel . notice where does it point to and make similar github repo for your port. which SPEC is used from rpm/ , in case of several SPEC files, is determined by OBS repo name. so, if name is community-adaptation-devel then corresponding spec is used. that way you |
| 10:53:29 | &lt;rinigus&gt;: will be able to define urls based on whether you build devel (for you) or testing (for users) version |
| 10:58:52 | *&lt;sharks&gt;*: rinigus - thanks! That's exactly what I was missing. Can I ask a follow-up? In some ports the developer has used `latest` repos, and in others they use `releasemajorminor`. In nagara you're using a bit of both. What is the rationale behind this? Is there one or the other that I should be using? |
| 11:06:16 | &lt;rinigus&gt;: sharks: obviously, nagara is using the best and the only correct approach. latest is used for devel. for user's facing testing, we define subproject https://build.sailfishos.org/project/subprojects/nemo:testing:hw:sony:nagara for each release. that allows you to add or drop packages between releases. has been battle tested in sony tama and some other ports |
| 11:08:25 | *&lt;sharks&gt;*: Right, cool. I noticed nagara has subprojects like that. Are they something I can create myself or do I need to ask for it from keto etc.? Right now I'm just focusing on getting the devel one going, so I'll use latest for that, and then once I've decided I know what I'm doing I want to retrace my steps and use devel as a guide to put the testing one together. |
| 11:10:12 | *&lt;sharks&gt;*: Oh - it looks like I can make my own subprojects. Cool! Thanks again rinigus, you're a handy bloke to have around. |
| 11:10:49 | &lt;rinigus&gt;: good luck! |
| 11:11:53 | *&lt;sharks&gt;*: Thanks, I might need it :) |
| 13:06:12 | *&lt;sharks&gt;*: Sorry to interrupt, quick question - What is out-of-image-files.files for? |
| 13:07:16 | <mark>&lt;mal&gt;</mark>: sharks: that lists what files will kept out side the installation zip |
| 13:07:58 | *&lt;sharks&gt;*: Thanks mal, in other words it's not mission critical |
| 13:11:03 | *&lt;sharks&gt;*: I've just tried to build my first image since all the LVM & OBS changes, and ended up with a new error trying to manually run `mic` per the hadk-hot |
| 13:11:07 | *&lt;sharks&gt;*: Info[07/17 13:03:45] : Running pack scripts ... |
| 13:11:07 | *&lt;sharks&gt;*: $ANDROID_ROOT/sfe-xqcc72-5.1.0.11devel1 $ANDROID_ROOT |
| 13:11:07 | *&lt;sharks&gt;*: Resize root and home |
| 13:11:07 | *&lt;sharks&gt;*: losetup: /dev/loop0: failed to set up loop device: No such file or directory |
| 13:11:07 | *&lt;sharks&gt;*: Info[07/17 13:03:45] : Script returned with non zero status, failing. |
| 13:11:08 | *&lt;sharks&gt;*: Error <creator>[07/17 13:03:46] : Failed to execute %pack script with /bin/bash |
| 13:12:44 | *&lt;sharks&gt;*: Seems like everything made it into the `sfe-xqcc72-5.1.0.11devel1` directory, but for whatever reason it couldn't jam it all into a *.zip |
| 13:14:44 | *&lt;sharks&gt;*: https://paste.opensuse.org/pastes/112e3a16e93a |
| 13:53:25 | *&lt;sharks&gt;*: When you manually run `sudo mic create fs`, the *.ks file you pass in from the ssu-kickstarts rpm is essentially the bash script that runs to do the work of creating the flashable image? If so, how come if I modify that file in order to try and debug this /dev/loop error, I don't see my modifications the next time I run the mic command? |
| 15:25:04 | <mark>&lt;mal&gt;</mark>: sharks: wait, how are you building the image? |
| 23:20:09 | *&lt;sharks&gt;*: @mal are you still around? |
| 23:21:04 | *&lt;sharks&gt;*: I was building the image per instructions from hadk-hot |
| 23:21:05 | *&lt;sharks&gt;*: https://sailfishos.wiki/link/20#bkmrk-%C2%A0%C2%A0%C2%A0%C2%A0%C2%A0%C2%A0%C2%A0-%2A-your-%24andr |

---
### 📅 2026-07-18

| Time | User & Message |
| :--- | :--- |
| 00:50:49 | **&lt;elros34&gt;**: if fpr some reason you choose to build lvm image then command is wrong. Look at build_packages.sh script |
| 00:51:12 | *&lt;sharks&gt;*: mal asked me to build an lvm image |
| 00:58:19 | *&lt;sharks&gt;*: Okay, thanks @elros34, I think I've spotted what you meant. There are two possible mic commands and the one for an lvm image is `mic create loop`, not `mic create fs` |
| 01:13:33 | *&lt;sharks&gt;*: Okay that got me further but I'm still doing something wrong, "cannot access flash.*': No such file or directory" |
| 01:17:15 | **&lt;elros34&gt;**: search for flash.* in droid repos for some lvm based device. Maybe it expect flashing script in some place |
| 01:20:55 | *&lt;sharks&gt;*: not in mer-hybris/droid-config-sony-murray, but maybe I can extract them from the official 10 IV zip from Jolla's website. Just don't know where to put them - are they supposed to be in droid-config somewhere? |
| 01:29:11 | **&lt;elros34&gt;**: https://github.com/search?q=org%3Amer-hybris%20flash.sh&type=code |
| 01:30:33 | *&lt;sharks&gt;*: Yep, I believe it's all the stuff in the `boot` directory, I just don't know where I'm supposed to get it from |
| 01:31:59 | **&lt;elros34&gt;**: what do you mean it's first search result, its in submodule |
| 01:33:33 | *&lt;sharks&gt;*: Well then that exists in my source tree at $ANDROID_ROOT/hybris/droid-configs/droid-configs-device/sparse/boot/flash.sh |
| 01:34:20 | *&lt;sharks&gt;*: So why can't `mic` find it? What's it want me to do that I haven't done? |
| 01:35:25 | **&lt;elros34&gt;**: second search entry shows it's supposed to be in out-of-image-files.files (https://github.com/mer-hybris/droid-config-sony-seine/blob/e47c164db8cdf08f69bae34f0145204265fbe5c8/out-of-image-files.files#L3). I ahve never se reason to try lvm build so take it with grain of salt |
| 01:37:05 | *&lt;sharks&gt;*: To be honest I'm not sure why an LVM build is a good idea either, you'll just end up with the problem everyone had when upgrading to 5.1 that there wasn't enough space on the partition, but anyway I was asked to do it by those smarter than me so I am trying to do as I was asked |
| 01:37:46 | *&lt;sharks&gt;*: You are right I don't have the out-of-image-files.files, but that lists eg. flash-on-windows.bat which doesn't exist in my sources locally, only adding to my confusion |
| 01:39:22 | **&lt;elros34&gt;**: search for flash-on-windows.bat  in mer-hybris repo |
| 01:40:05 | **&lt;elros34&gt;**: you can see it's in sparse |
| 01:40:18 | *&lt;sharks&gt;*: Yep, just spotted that |
| 01:40:38 | *&lt;sharks&gt;*: Okay, thanks elros, I'll add the boot directory to sparse and see if that helps. |
| 02:02:50 | *&lt;sharks&gt;*: Nope, that didn't fix it |
| 02:04:46 | *&lt;sharks&gt;*: Screw it, until someone who knows more about LVM images can tell me what I'm doing wrong, I'll just comment out the bits about the flash files in the .ks file. |
| 02:16:18 | <mark>&lt;mal&gt;</mark>: you should just remove the flash file stuff from the pack kickstart https://github.com/mlehtima/droid-config-fp5/blob/master/kickstart/pack/fp5/hybris#L109 |
| 02:16:30 | <mark>&lt;mal&gt;</mark>: if that was the issue |
| 02:17:56 | <mark>&lt;mal&gt;</mark>: and you can define the size of the root partition, I use 10 GB on fairphones |
| 02:43:00 | *&lt;sharks&gt;*: Sorry, I had to step out for half an hour |
| 02:44:25 | *&lt;sharks&gt;*: I have removed the flash file stuff from the kickstart, I'll rerun the mic command and see if I can get an image to pop out the other end |
| 02:52:52 | <mark>&lt;mal&gt;</mark>: did you rebuild config packages first with build_packages.sh -c? |
| 02:53:09 | <mark>&lt;mal&gt;</mark>: I mean if you do the change I mentioned |
| 02:53:45 | *&lt;sharks&gt;*: Umm |
| 02:54:00 | *&lt;sharks&gt;*: no because I just changed the *.ks file I'm feeding into `mic` |
| 02:55:45 | *&lt;sharks&gt;*: Maybe that's the wrong thing to do but I don't even know if this LVM image is going to successfully go together and boot yet. If it works I'll go back and update droid-configs - but then if I trigger services on OBS, it should rebuild that, right? I don't have to run `build_packages.sh -c` locally anymore? |
| 02:57:10 | *&lt;sharks&gt;*: Nevermind, mic failed again so I'm doing something wrong. |
| 02:58:08 | *&lt;sharks&gt;*: I wish there was a way to just test these last 15 lines of the *.ks script without having to wait for mic to organise all the packages and build the rootfs and everything first |
| 02:59:10 | *&lt;sharks&gt;*: Maybe I can run them manually in the output directory |
| 03:15:58 | <mark>&lt;mal&gt;</mark>: did you setup boot-img package already? |
| 03:16:36 | *&lt;sharks&gt;*: This one? https://build.sailfishos.org/package/show/nemo:devel:hw:sony:murray/droid-hal-img-boot-sony-xqcc72 |
| 03:17:20 | <mark>&lt;mal&gt;</mark>: yes |
| 03:17:25 | *&lt;sharks&gt;*: And I also ran build-packages -b /path/to/droid-hal-img-boot-sony-xqcc72 though as I say my understanding is that this *.ks file is supposed to pull packages from OBS not from local repo |
| 03:24:46 | *&lt;sharks&gt;*: Okay, removing the line `chmod 755 flash.*` and removing "flash.*" from the FILES variable gave me an image. But I'm not getting gui anymore, can only telnet |
| 03:25:21 | *&lt;sharks&gt;*: On port 23 |
| 03:37:40 | *&lt;sharks&gt;*: So I flashed boot with `fastboot flash boot hybris-boot.img` and rootfs with `fastboot flash userdata sailfish.img001`, but I've got "exFAT-fs (sda74): invalid boot record signature", "exFAT-fs (sda74): failed to read boot sector", "exFAT-fs (sda74): failed to recognize exfat type", "F2FS-fs (sda74): Magic Mismatch, valid(0xf2f52010) - read(0x0)", "F2FS-fs (sda74): Can't find valid F2FS filesystem in 1th superblock" in dmesg on device. |
| 03:39:18 | *&lt;sharks&gt;*: So userdata (sda74) is not mounting. It sounds to me like it's still trying to boot with a community-style userdata partition not an LVM one, but I don't know why or how |
| 03:42:18 | *&lt;sharks&gt;*: @mal you said I didn't have to `make hybris-boot` again after switching to LVM? There was nothing I had to do in the HABUILD environment? |
| 03:42:43 | *&lt;sharks&gt;*: I don't fully understand how droid-hal-img-boot works |
| 03:43:32 | *&lt;sharks&gt;*: I mean it makes a boot image but where does it put it? How can I be sure that's what made it onto my device? |
| 05:13:25 | *&lt;sharks&gt;*: @mal where do the flash.* files get pulled into the archive from? |
| 05:24:07 | *&lt;sharks&gt;*: Cripes I'm so confused. The hybris-boot.img that made it into my LVM archive was from ./out/target/product/pdx225/hybris-boot.img (confirmed by checking md5 hash). The boot-img package output is at ./hybris/droid-hal-img-boot-sony-xqcc72/hybris-boot.img because there is no documentation as to where to put it, so I took a guess that would do. Either I put it in the wrong place and `mic` didn't pick it up, or something else is wrong. |
| 05:24:43 | *&lt;sharks&gt;*: At any rate, flashing with the hybris-boot from droid-hal-img-boot gets me to the first setup screen, but my touchscreen no longer works |
| 05:25:26 | *&lt;sharks&gt;*: And the phone will not connect over USB so I'm completely locked out, just stuck looking at a language selection screen |
| 05:25:37 | *&lt;sharks&gt;*: But at least I suppose that means I've got the filesystem up |
| 05:25:55 | *&lt;sharks&gt;*: Any idea where to go from here? |
| 06:33:58 | &lt;rinigus&gt;: sharks: its been a while since I used LVM in a port. but some notes are at https://github.com/sailfishos-sony-tama/main/blob/hybris-10/hadk-sony-xz2.md . not all has to be followed (you don't package android itself, for example), but maybe there are some bits that can help |
| 09:11:11 | *&lt;sharks&gt;*: Oh yeah! I had the bright idea to plug a mouse into the USB port, and now I can interact with the phone! No touchscreen, but also no blind debugging |
| 09:13:00 | *&lt;sharks&gt;*: Except that they keyboard doesn't come up if a mouse is plugged in, damn. |
| 09:13:18 | *&lt;sharks&gt;*: And wlan is dead as well as touchscreen |
| 09:14:13 | *&lt;sharks&gt;*: It's like the modules-load.d/xqcc72.conf isn't happening |
| 09:17:10 | *&lt;sharks&gt;*: "bash: modprobe: not found" |
| 09:17:12 | *&lt;sharks&gt;*: what the heck? |
| 09:19:26 | *&lt;sharks&gt;*: `#/system/bin/modprobe wlan` --> "modprobe: failed to scan dir /lib/modules/: no such file or directory" |
| 09:19:42 | *&lt;sharks&gt;*: What has this LVM image done to me?? |
| 09:24:47 | *&lt;sharks&gt;*: Damn, I haven't got bluetooth either |
| 09:24:54 | *&lt;sharks&gt;*: I've got no way to get logs off the device |
| 09:28:46 | *&lt;sharks&gt;*: Can't see any mount errors in journal. But /lib/ only contains /lib/udev/ and /lib/ld-linux-aarch64.so.1 |
| 09:36:54 | *&lt;sharks&gt;*: Modules are in /vendor_dlkm/lib/modules but they refuse to load with "Exec format error" |
| 09:39:10 | *&lt;sharks&gt;*: `uname -r` gives "5.4.300" and `strings /vendor_dlkm/lib/modules/wlan.ko \| grep vermagic` gives "5.4.296". Why the heck did it work before and not now? |
| 09:44:21 | *&lt;sharks&gt;*: @mal how does droid-hal-img-boot get the kernel version? Is that what my problem is, that it's picked the wrong one? |
| 09:51:10 | *&lt;sharks&gt;*: I think that is the problem. I don't understand it, but however droid-hal-img-boot gets a kernel together, it's got the wrong one. |
| 09:51:10 | *&lt;sharks&gt;*: That or I'm talking complete rubbish, but my understanding of this whole LVM thing is next to zero |
| 10:38:09 | *&lt;sharks&gt;*: So just about the only thing working on the phone is the SD card slot, which means I managed to get the journal log off it and onto the computer --> https://paste.opensuse.org/pastes/892d9c8b4c45 |
| 10:55:00 | *&lt;sharks&gt;*: Okay - using that sdcard, I copied /lib/modules/ from a previous "community style" .stowaways/sailfishos/lib/modules rootfs .tar.bz2 onto the device, and now what do you know? Wifi and touch and sound and camera and all the other broken things are now working |
| 10:55:42 | *&lt;sharks&gt;*: So it was not that droid-hal-img-boot wasn't using the right kernel, it's that the rootfs of this LVM style image isn't copying in all the same files and directories as the rootfs of the community style image did |
| 10:56:14 | *&lt;sharks&gt;*: So now I have to work out why that is |
| 10:57:21 | **&lt;elros34&gt;**: whether it's common tarball or image files are not copied to rootfs, everything is rpm package |
| 10:58:02 | **&lt;elros34&gt;**: so if you are missing modules then either you are missing some rpm package or some rpm package wasn't created correctly |
| 10:59:02 | *&lt;sharks&gt;*: Mal told me to remove droid-hal-pdx225-kernel-modules from patterns to go LVM |
| 10:59:03 | *&lt;sharks&gt;*: https://github.com/sharks-dev/droid-config-pdx225/commit/565be83b97a50bc98e0f548527cdde0f8e6a99bf |
| 10:59:09 | *&lt;sharks&gt;*: Is that it? |
| 11:02:49 | **&lt;elros34&gt;**: dunno but you can for example unpack rpm and see whether it contains modules: https://build.sailfishos.org/package/binary/nemo:testing:hw:fairphone:fp4/droid-hal-img-boot-fp4?arch=aarch64&filename=droid-hal-fp4-img-boot-1.0.0-1.1.1.bso.aarch64.rpm&repository=sailfishos_5.1 |
| 11:04:53 | *&lt;sharks&gt;*: Yeah that's exactly where it is |
| 11:06:04 | *&lt;sharks&gt;*: So why did mal tell me to take it out? They cost me a day of my life because of that silly idea! |
| 11:06:04 | *&lt;sharks&gt;*: https://irclogs.sailfishos.org/logs/%23sailfishos-porters/2026/%23sailfishos-porters.2026-07-15.log.html#t2026-07-15T11:01:02 |
| 11:10:54 | **&lt;elros34&gt;**: so modules are in droid-hal-device-img-boot? Did you unpack rpm? |
| 11:11:24 | *&lt;sharks&gt;*: No, modules are in droid-hal-pdx225-kernel-modules rpm |
| 11:11:34 | *&lt;sharks&gt;*: But I was told to remove that from patterns |
| 11:12:24 | **&lt;elros34&gt;**: forget for a secund abot that. What about droid-hal-fp4-img-boot? |
| 11:15:05 | *&lt;sharks&gt;*: I can't unpack that rpm with `7z x path/to/the/rpm.rpm` like I normally do |
| 11:15:17 | *&lt;sharks&gt;*: "Cannot open the file as archive" |
| 11:15:26 | **&lt;elros34&gt;**: use any gui archive manager |
| 11:16:04 | *&lt;sharks&gt;*: Okay dunno why 7z didn't work but xarchiver has |
| 11:16:22 | *&lt;sharks&gt;*: And yes okay, point taken, that archive does indeed also contain /lib/modules |
| 11:16:30 | *&lt;sharks&gt;*: Let me check mine I guess |
| 11:17:42 | *&lt;sharks&gt;*: Mine DOES contain modules |
| 11:17:44 | *&lt;sharks&gt;*: what the heck |
| 11:17:52 | *&lt;sharks&gt;*: why didn't it make it to the device then? |
| 11:18:00 | *&lt;sharks&gt;*: Man my head hurts |
| 11:21:27 | **&lt;elros34&gt;**: do you file *.packages or something like that in same directory as generated sfos image? If it's there then it should have list of all installed packages and versions |
| 11:25:13 | *&lt;sharks&gt;*: Good point, yes there is a *.packages file and yes it lists the version of droid-hal-pdx225-img-boot as one that's a few days older than the current one |
| 11:29:08 | **&lt;elros34&gt;**: hmm what repositories do you see in ks file? local or one from obs? |
| 11:29:20 | *&lt;sharks&gt;*: Obs, which should be right |
| 11:29:31 | *&lt;sharks&gt;*: I wonder if mic took an older version from the cache?? |
| 11:30:16 | *&lt;sharks&gt;*: Yeah, I deleted the cache and ran mic again, and I can see it's downloading the correct rpms... |
| 11:30:27 | **&lt;elros34&gt;**: when you run mic I think it should show what repos it uses |
| 11:31:42 | *&lt;sharks&gt;*: I think mic is working this time around, maybe something went wrong the first time. I probably should have checked what was in the cache before deleting it |
| 11:32:20 | **&lt;elros34&gt;**: I seriously doubt cache has anything to it |
| 11:32:50 | *&lt;sharks&gt;*: I don't know man |
| 11:32:59 | *&lt;sharks&gt;*: I've been beating my head against a wall for 12 hours now |
| 11:33:13 | *&lt;sharks&gt;*: and it appears promising at the minute so I'm holding onto that hope |
| 11:33:21 | *&lt;sharks&gt;*: I'll report back once mic has finished |
| 11:42:35 | <mark>&lt;mal&gt;</mark>: sharks: the reason for removing kernel module package from patterns was the in lvm based those are in boot-img package, also build_packages.sh -i detects which build type to use (fs or loop) based on existence of kernel module package in patterns |
| 11:43:20 | *&lt;sharks&gt;*: Yes, sorry mal, at long last I have worked that much out - well, not the bit about build_packages.sh but the bit about where the modules went |
| 11:44:08 | <mark>&lt;mal&gt;</mark>: yeah, having wrong package version of boot image package was quite unfortunate |
| 11:44:13 | *&lt;sharks&gt;*: What I don't understand is why I am missing "flash.*" that the *.ks file wants, and why I am even running build_packages.sh at all anymore given everything should now come from OBS as far as I understand |
| 11:45:05 | *&lt;sharks&gt;*: Yes, I don't know why it had the wrong version of the boot image, I must have made a mistake somewhere but it took me forever to work it out. If elros hadn't come along I'd still be here this time next week wondering what was going on |
| 11:55:26 | *&lt;sharks&gt;*: Okay hangon |
| 11:55:53 | *&lt;sharks&gt;*: @mal where do I get hybris-boot from for the LVM image? That's still an outstanding problem and possibly partially what led to this issue I've had |
| 11:57:32 | *&lt;sharks&gt;*: mic is still picking up the community hybris-boot that was made in the habuild environment which doesn't work, so I have to run `build_packages.sh -b droid-hal-img-boot-sony-xqcc72` to get an LVM one |
| 11:58:20 | *&lt;sharks&gt;*: I think anyway, checking that now |
| 11:58:46 | *&lt;sharks&gt;*: But I don't understand how `mic` works and why it's still grabbing the old one |
| 12:00:00 | **&lt;elros34&gt;**: mic simply install pattern package (which has all other dependencies) defined in ks file from repos defined in ks file |
| 12:02:48 | *&lt;sharks&gt;*: hmm no it's not build_packages.sh that makes hybris-boot.img, how the heck did I end up making droid-hal-img-boot/hybris-boot.img the first time?? |
| 12:04:42 | *&lt;sharks&gt;*: @elros34 the *.ks pulls from droid-configs/kickstart/attachment/xqcc72 where it lists /boot/hybris-boot.img, but I don't understand where that is on the filesystem in relation to $ANDROID_ROOT, and who puts it there |
| 12:07:53 | *&lt;sharks&gt;*: hangon, my bad, it is build_packages.sh that makes hybris-boot.img, my brain is too fried |
| 12:08:23 | *&lt;sharks&gt;*: okay, I still don't know why the ks file picks the old one from the community style port but at least I should be able to boot shortly |
| 12:10:54 | *&lt;sharks&gt;*: Oh cripes and I still have no touchscreen |
| 12:12:44 | **&lt;elros34&gt;**: I don't get all of this but I hope you are running mic manually not with build_packages.sh |
| 12:13:20 | *&lt;sharks&gt;*: I don't get all of it either |
| 12:13:33 | *&lt;sharks&gt;*: but yes, I run mic with `sudo mic create loop --arch=$PORT_ARCH --tokenmap=ARCH:$PORT_ARCH,RELEASE:$RELEASE,EXTRA_NAME:$EXTRA_NAME --record-pkgs=name,url --outdir=sfe-$DEVICE-$RELEASE$EXTRA_NAME --copy-kernel "$ANDROID_ROOT"/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks` |
| 12:15:08 | **&lt;elros34&gt;**: so image still have wrong rpm? |
| 12:16:48 | *&lt;sharks&gt;*: Yep |
| 12:17:16 | *&lt;sharks&gt;*: But I swear I saw mic download the right one from obs |
| 12:17:43 | **&lt;elros34&gt;**: are you sure you don't mix up output directories? |
| 12:19:01 | *&lt;sharks&gt;*: New EXTRA_NAME every time so that shouldn't happen |
| 12:19:59 | <mark>&lt;mal&gt;</mark>: sharks: what are the versions of the img-boot packages? |
| 12:20:33 | *&lt;sharks&gt;*: The one that contains /lib is on OBS, "droid-hal-pdx225-img-boot-0.0.1+master.20260717093415.e0ba226-1.5.1.bso.aarch64.rpm" |
| 12:20:58 | *&lt;sharks&gt;*: The one that does not is idk where, about to run a `find` command but it's version `droid-hal-pdx225-img-boot.aarch64 0.0.6-202607151028` |
| 12:21:02 | <mark>&lt;mal&gt;</mark>: well the local built ones have 0.0.6* version |
| 12:21:06 | <mark>&lt;mal&gt;</mark>: which is bigger |
| 12:21:36 | *&lt;sharks&gt;*: Yeah - but why is mic picking up a local built one? The ks file doesn't have the local repo in it? |
| 12:21:58 | <mark>&lt;mal&gt;</mark>: did you check the urls in .ks? |
| 12:22:45 | <mark>&lt;mal&gt;</mark>: it by default uses local repo (unless you had correct community-adaptation during the generation of the .ks to make it setup obs url) |
| 12:23:15 | *&lt;sharks&gt;*: This is the .ks --> https://github.com/sharks-dev/sailfish-on-murray/blob/main/Jolla-%40RELEASE%40-xqcc72-%40ARCH%40.ks |
| 12:24:09 | *&lt;sharks&gt;*: And this is how I'm using it --> https://github.com/sharks-dev/sailfish-on-murray/blob/main/README.md#building-an-lvm-devel-image |
| 12:26:02 | **&lt;elros34&gt;**: better show paste from terminal. For example I can image you are not using that one ks file you posted link |
| 12:27:11 | *&lt;sharks&gt;*: Sure --> https://paste.opensuse.org/pastes/ce1b1109b600 |
| 12:28:15 | **&lt;elros34&gt;**: and now cat $ANDROID_ROOT"/Jolla-@RELEASE@-$DEVICE-@ARCH@.ks |
| 12:28:19 | <mark>&lt;mal&gt;</mark>: sharks: the issue is that you added img-boot and img-recovery here https://build.sailfishos.org/package/show/nemo:devel:hw:sony:murray/droid-hal-pdx225 |
| 12:28:32 | <mark>&lt;mal&gt;</mark>: when using lvm based build the prebuilt packages should not have it |
| 12:29:32 | <mark>&lt;mal&gt;</mark>: so now because the img-boot repo you have is not tagged it gets some smaller version number and it installs wrong ones |
| 12:29:53 | <mark>&lt;mal&gt;</mark>: so remove those img-boot and img-recovery rpms from https://build.sailfishos.org/package/show/nemo:devel:hw:sony:murray/droid-hal-pdx225 |
| 12:31:12 | *&lt;sharks&gt;*: Crikey, thanks mal, I never would have worked that out |
| 12:31:37 | <mark>&lt;mal&gt;</mark>: I have made the mistake before also :) |
| 12:31:45 | *&lt;sharks&gt;*: I think I copied nagara when I uploaded those rpms, I never considered it would cause issues!! |
| 12:32:00 | *&lt;sharks&gt;*: Oh man, I will never make that mistake again thats for sure :) |
| 12:32:22 | **&lt;elros34&gt;**: btw not related to mic but in your readme you have link to some very old hadk pdf. It's web based now |
| 12:32:33 | *&lt;sharks&gt;*: Okay, I've deleted them so I will re-run mic, will see what happens this time |
| 12:33:48 | *&lt;sharks&gt;*: @elros34 yes I do have a link to an old hadk pdf. It's the most recent one I could find. I realise it's web based now but I did not like the interface when I tried to use it, the pdf was easier to read and it's what I used a few years ago when I first attempted to port a device so I was more familiar with navigating through it. |
| 12:34:11 | <mark>&lt;mal&gt;</mark>: https://hadk.sailfishos.org/ |
| 12:34:46 | <mark>&lt;mal&gt;</mark>: I find that easier since you can link to sections to show other |
| 12:37:06 | *&lt;sharks&gt;*: I think when I started this port a few weeks ago I decided I did not like it because I couldn't crtl+f through it very easily |
| 12:37:47 | *&lt;sharks&gt;*: eg. if I was in the wrong section and I wanted to remember how to set the persistent logging of the journal, I can't crtl+f for "automatic" and easily read the path of the file where you have to set that value |
| 12:38:02 | *&lt;sharks&gt;*: Instead I have to remember which heading it is under or try each one manually |
| 12:38:09 | *&lt;sharks&gt;*: I find it easier just to have the pdf open |
| 12:39:16 | *&lt;sharks&gt;*: It is just personal preference I guess, perhaps I am a luddite |
| 12:40:35 | <mark>&lt;mal&gt;</mark>: maybe I could see if there is a way to make single page version of the web version |
| 12:41:20 | *&lt;sharks&gt;*: If you could that would work great |
| 12:41:30 | **&lt;elros34&gt;**: fair point, addition pdf would be nice too |
| 12:41:31 | *&lt;sharks&gt;*: But it's entirely possible I'm the only person with that complaint |
| 12:42:23 | <mark>&lt;mal&gt;</mark>: also when people use pdf they might have some old pdf |
| 12:43:31 | **&lt;elros34&gt;**: sharks but using outdated pdf also gives you headach right?:P Didn't you have outdated droid-hal-device.conf with hardcoded touchscreen node which we don't use anymore |
| 12:44:53 | <mark>&lt;mal&gt;</mark>: maybe I should try to boot my new fp6 image today, new android base since previous image |
| 12:45:04 | *&lt;sharks&gt;*: @elros34 that is entirely correct, you have caught me there |
| 12:47:07 | **&lt;elros34&gt;**: I also had issues with finding right line in all chapters  of web version so I get you |
| 12:47:38 | *&lt;sharks&gt;*: Yeah, easier I think when it's all on one page like hadk-hot and hadk-faq |
| 12:47:40 | <mark>&lt;mal&gt;</mark>: and historically copy-paste of commands from pdf has caused a lot of issues |
| 12:47:57 | <mark>&lt;mal&gt;</mark>: multiline commands that is |
| 12:48:22 | *&lt;sharks&gt;*: Yes, I can see how multiline commands on a pdf would be painful. Web version certainly fixes that |
| 12:49:14 | **&lt;elros34&gt;**: this arrow/multiline in droid-hal-device.conf in pdf affected many porters |
| 12:52:45 | *&lt;sharks&gt;*: I have mentioned it somewhere before but I must say despite the trouble I've had with this last step of turning it into an LVM image, actually getting sailfishos running on the device and all major functions working was far easier this time than last time I tried it a few years ago. I think you've done a lot of work getting these later android bases working well and I really appreciate it, far above my skill level. |
| 12:54:22 | <mark>&lt;mal&gt;</mark>: newer android bases are usually simpler, once we (usually I though) have figured out the things needed for those |
| 12:55:30 | *&lt;sharks&gt;*: Yes, I can see it's usually you haha :) |
| 12:55:43 | **&lt;elros34&gt;**: I guess move for libhybris to binder helps right? |
| 12:56:01 | <mark>&lt;mal&gt;</mark>: yes, binder has made many things simpler |
| 13:00:23 | *&lt;sharks&gt;*: Wahoo! It works!! |
| 13:00:41 | *&lt;sharks&gt;*: Thankyou again mal, it was those two rpms in obs that caused it |
| 13:01:24 | *&lt;sharks&gt;*: Now I just have to duplicate everything I did in the devel project into the testing project and I have an image people can use |
| 13:29:30 | *&lt;sharks&gt;*: Hmmm I have a new dumb question |
| 13:30:34 | *&lt;sharks&gt;*: How can I be sure the device is actually looking to my obs project for updates etc.? `zypper lr -u` lists adaptation-common for example but not adaptation-common-xqcc72-@RELEASE@ like was in the .ks file |
| 13:30:46 | *&lt;sharks&gt;*: Have I missed another step? |
| 13:32:59 | <mark>&lt;mal&gt;</mark>: what repos do you have in output of "ssu lr" |
| 13:33:37 | *&lt;sharks&gt;*: Ah, thanks mal, that shows it is there. I have eg. "adaptation-community        ... https://repo.sailfishos.org/obs/nemo:/devel:/hw:/sony:/murray/sailfish_latest_aarch64/" |
| 13:33:51 | *&lt;sharks&gt;*: So it is working. I just didn't know how to check |
| 13:33:55 | *&lt;sharks&gt;*: Thankyou |
| 13:38:57 | **&lt;elros34&gt;**: always use ssu for adding/removing repos instead zypper |
| 13:39:50 | <mark>&lt;mal&gt;</mark>: yes, zypper should be only used for installing or removing packages, on official devices we don't have zypper installed by default and pkcon is used |
| 13:40:24 | *&lt;sharks&gt;*: I certainly wasn't planning on adding or removing repos, just checking which ones were there. I use pkcon for most things except installing local rpms which I use zypper for. |
| 13:40:41 | *&lt;sharks&gt;*: I do recall when I was running official sfos, I had to manually install zypper |
| 13:41:15 | *&lt;sharks&gt;*: Oh also - @Keto, may I please have store access? `ssu s` --> "Device model: Xperia 10 IV (xqcc72 / community)" |
| 13:58:28 | &lt;Keto&gt;: sharks: done |
| 14:00:05 | *&lt;sharks&gt;*: Thanks muchly, appears to work fine now :) |
