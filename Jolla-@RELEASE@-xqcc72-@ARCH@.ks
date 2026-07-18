# DisplayName: Jolla xqcc72/@ARCH@ (release) 1+master.20260718014740.c35d49f
# KickstartType: release
# DeviceModel: xqcc72
# DeviceVariant: xqcc72
# Brand: Jolla
# SuggestedImageType: fs
# SuggestedArchitecture: aarch64

timezone --utc UTC

### Commands from /tmp/sandbox/usr/share/ssu/kickstart/part/xqcc72
part / --fstype="ext4" --size=4000 --label=root
part /home --fstype="ext4" --size=800 --label=home

## No suitable configuration found in /tmp/sandbox/usr/share/ssu/kickstart/bootloader

repo --name=adaptation-common-xqcc72-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla-hw/adaptation-common/@ARCH@/
repo --name=adaptation-community-xqcc72-@RELEASE@ --baseurl=https://repo.sailfishos.org/obs/nemo:/devel:/hw:/sony:/murray/sailfish_latest_@ARCH@/
repo --name=adaptation-community-common-xqcc72-@RELEASE@ --baseurl=https://repo.sailfishos.org/obs/nemo:/devel:/hw:/common/sailfish_latest_@ARCH@/
repo --name=apps-@RELEASE@ --baseurl=https://releases.jolla.com/jolla-apps/@RELEASE@/@ARCH@/
repo --name=hotfixes-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/hotfixes/@ARCH@/
repo --name=jolla-@RELEASE@ --baseurl=https://releases.jolla.com/releases/@RELEASE@/jolla/@ARCH@/

%packages
patterns-sailfish-device-configuration-xqcc72
%end

%attachment
### Commands from /tmp/sandbox/usr/share/ssu/kickstart/attachment/xqcc72
/boot/hybris-boot.img
/boot/hybris-recovery.img
/boot/dtbo.img
droid-config-xqcc72-out-of-image-files
droid-flashing-tools
/etc/hw-release
%end

%pre --erroronfail
export SSU_RELEASE_TYPE=release
### begin 01_init
touch $INSTALL_ROOT/.bootstrap
### end 01_init
%end

%post --erroronfail
export SSU_RELEASE_TYPE=release
### begin 01_arch-hack
if [ "@ARCH@" == armv7hl ] || [ "@ARCH@" == armv7tnhl ] || [ "@ARCH@" == aarch64 ]; then
    # Without this line the rpm does not get the architecture right.
    echo -n "@ARCH@-meego-linux" > /etc/rpm/platform

    # Also libzypp has problems in autodetecting the architecture so we force tha as well.
    # https://bugs.meego.com/show_bug.cgi?id=11484
    echo "arch = @ARCH@" >> /etc/zypp/zypp.conf
fi
### end 01_arch-hack
### begin 01_rpm-rebuilddb
# Rebuild db using target's rpm
echo -n "Rebuilding db using target rpm.."
rm -f /var/lib/rpm/__db*
rpm --rebuilddb
echo "done"
### end 01_rpm-rebuilddb
### begin 50_oneshot
# exit boostrap mode
rm -f /.bootstrap

# export some important variables until there's a better solution
export LANG=en_US.UTF-8
export LC_COLLATE=en_US.UTF-8

# run the oneshot triggers for root and first user uid
UID_MIN=$(grep "^UID_MIN" /etc/login.defs |  tr -s " " | cut -d " " -f2)
DEVICEUSER=`getent passwd $UID_MIN | sed 's/:.*//'`

if [ -x /usr/bin/oneshot ]; then
   /usr/bin/oneshot --mic
   su -c "/usr/bin/oneshot --mic" $DEVICEUSER
fi
### end 50_oneshot
### begin 60_ssu
if [ "$SSU_RELEASE_TYPE" = "rnd" ]; then
    [ -n "@RELEASE@" ] && ssu release -r @RELEASE@
    [ -n "@FLAVOUR@" ] && ssu flavour @FLAVOUR@
    ssu mode 2
else
    [ -n "@RELEASE@" ] && ssu release @RELEASE@
    ssu mode 4
fi
### end 60_ssu
%end

%post --nochroot --erroronfail
export SSU_RELEASE_TYPE=release
### begin 50_os-release
(
CUSTOMERS=$(find $INSTALL_ROOT/usr/share/ssu/features.d -name 'customer-*.ini' \
    |xargs --no-run-if-empty sed -n 's/^name[[:space:]]*=[[:space:]]*//p')

cat $INSTALL_ROOT/etc/os-release
echo "SAILFISH_CUSTOMER=\"${CUSTOMERS//$'\n'/ }\""
) > $IMG_OUT_DIR/os-release
### end 50_os-release
### begin 99_check_shadow
IS_BAD=0

echo "Checking that no user has password set in /etc/shadow."
# This grep prints users that have password set, normally nothing
if grep -vE '^[^:]+:[*!]{1,2}:' $INSTALL_ROOT/etc/shadow
then
    echo "A USER HAS PASSWORD SET! THE IMAGE IS NOT SAFE!"
    IS_BAD=1
fi

# Checking that all users use shadow in passwd,
# if they weren't the check above would be useless
if grep -vE '^[^:]+:x:' $INSTALL_ROOT/etc/passwd
then
    echo "BAD PASSWORD IN /etc/passwd! THE IMAGE IS NOT SAFE!"
    IS_BAD=1
fi

# Fail image build if checks fail
[ $IS_BAD -eq 0 ] && echo "No passwords set, good." || exit 1
### end 99_check_shadow
%end

%pack --erroronfail
export SSU_RELEASE_TYPE=release
### begin hybris
pushd $IMG_OUT_DIR

MD5SUMFILE=md5.lst

DEVICE_VERSION_FILE=./hw-release

if [ -n "@EXTRA_NAME@" ] && [ "@EXTRA_NAME@" != @"EXTRA_NAME"@ ]; then
  EXTRA_NAME="@EXTRA_NAME@-"
fi

if [[ -a $DEVICE_VERSION_FILE ]]; then
  source $DEVICE_VERSION_FILE
  DEVICE_ID=-${MER_HA_DEVICE// /_}-$VERSION_ID
fi

source ./os-release
if [ "$SSU_RELEASE_TYPE" = "rnd" ]; then
  RND_FLAVOUR=$SAILFISH_FLAVOUR
fi

RELEASENAME=${NAME// /_}-${SAILFISH_CUSTOMER// /_}${SAILFISH_CUSTOMER:+-}${EXTRA_NAME// /_}$RND_FLAVOUR${RND_FLAVOUR:+-}$VERSION_ID$DEVICE_ID

IMGSECTORS=0
IMGBLOCKS=0
IMGSIZE=0
BLOCKSIZE=0

resizeloop() {
  local IMG=$1
  local LOOP=$(/sbin/losetup -f)
  /sbin/losetup $LOOP $IMG
  /sbin/e2fsck -f -y $LOOP

  # Get image blocks and free blocks
  local BLOCKCOUNT=$(/sbin/dumpe2fs -h $LOOP 2>&1 | grep "Block count:" | grep -o -E '[0-9]+')
  local FREEBLOCKS=$(/sbin/dumpe2fs -h $LOOP 2>&1 | grep "Free blocks:" | grep -o -E '[0-9]+')
  BLOCKSIZE=$(/sbin/dumpe2fs -h $LOOP 2>&1 | grep "Block size:" | grep -o -E '[0-9]+')
  echo "$IMG total block count: $BLOCKCOUNT - Free blocks: $FREEBLOCKS"

  local IMAGEBLOCKS=$(/usr/bin/expr $BLOCKCOUNT - $FREEBLOCKS)
  local IMAGESECTORS=$(/usr/bin/expr $IMAGEBLOCKS \* $BLOCKSIZE / 512 )

  # Shrink to minimum
  echo "Shrink $IMG to $IMAGESECTORS"
  /sbin/resize2fs $LOOP ${IMAGESECTORS}s -f

  # Get the size after resize.
  IMGBLOCKS=$(/sbin/dumpe2fs -h $LOOP 2>&1 | grep "Block count:" | grep -o -E '[0-9]+')
  IMGSIZE=$(/usr/bin/expr $IMGBLOCKS \* $BLOCKSIZE)
  IMGSECTORS=$(/usr/bin/expr $IMGBLOCKS \* $BLOCKSIZE / 512)
  echo "$IMG resized block count: $IMGBLOCKS - Block size: $BLOCKSIZE - Sectors: $IMGSECTORS - Total size: $IMGSIZE"

  /sbin/losetup -d $LOOP
}

echo "Resize root and home"

# Resize root and home to minimum
resizeloop root.img

ROOTSIZE=$IMGSIZE
ROOTBLOCKS=$IMGBLOCKS
ROOTSECTORS=$IMGSECTORS

resizeloop home.img

HOMESIZE=$IMGSIZE
HOMEBLOCKS=$IMGBLOCKS
HOMESECTORS=$IMGSECTORS

# We will add some (100M) extra to temp image.
TEMPIMGSECTORS=$(/usr/bin/expr $ROOTSECTORS + $HOMESECTORS + 200000 )

dd if=/dev/zero bs=512 count=0 of=temp.img seek=$TEMPIMGSECTORS

LVM_LOOP=$(/sbin/losetup -f)
/sbin/losetup $LVM_LOOP temp.img
/usr/sbin/pvcreate $LVM_LOOP
/usr/sbin/vgcreate sailfish $LVM_LOOP

echo "Create logical volume ROOT size: $ROOTSIZE"
/usr/sbin/lvcreate -L ${ROOTSIZE}B --name root sailfish

echo "Create logical volume HOME size: $HOMESIZE"
/usr/sbin/lvcreate -L ${HOMESIZE}B --name home sailfish

/bin/sync
/usr/sbin/vgchange -a y sailfish

dd if=root.img bs=$BLOCKSIZE count=$ROOTBLOCKS of=/dev/sailfish/root

dd if=home.img bs=$BLOCKSIZE count=$HOMEBLOCKS of=/dev/sailfish/home

/usr/sbin/vgchange -a n sailfish

rm home.img root.img

/sbin/losetup -d $LVM_LOOP

mv temp.img sailfish.img

/usr/bin/atruncate sailfish.img
# To make the file magic right lets convert to single file sparse image.
/usr/bin/img2simg sailfish.img sailfish.img001
rm sailfish.img

#chmod 755 flash.*

FILES="*.img* *.exe *.dll *-release"

# Set supported devices in flash scripts
if [ "@DEVICEMODEL@" = "xqcc72" ]; then
  sed -e "s/\@VALID_PRODUCTS\@/\"XQ-CC72\"/g" -i flash-config.sh
  sed -e "s/\@DEVICES\@/:: XQ-CC72/g" -i flash-on-windows.bat
fi

mkdir -p ${RELEASENAME}

mv ${FILES} ${RELEASENAME}/

# Calculate md5sums of files included to the archive
cd ${RELEASENAME}
md5sum * > $MD5SUMFILE
cd ..

# Package stuff back to archive
zip -r ${RELEASENAME}.zip $RELEASENAME

# Remove the files from the output directory
rm -r ${RELEASENAME}

popd
### end hybris
%end