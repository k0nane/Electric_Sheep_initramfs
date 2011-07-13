#!/system/bin/sh
# custom init script by thomasskull666 for SCH-R910

/sbin/busybox mount -o remount,rw /dev/block/stl10 /system
/sbin/busybox mount -o remount,rw / /

# Install busybox
/sbin/busybox mkdir /bin
/sbin/busybox --install -s /bin
rm -rf /system/xbin/busybox
ln -s /sbin/busybox /system/xbin/busybox
rm -rf /res
sync

# Fix permissions in /sbin, just in case
chmod 755 /sbin/*

# Fix screwy ownerships
for blip in conf default.prop fota.rc init init.goldfish.rc init.rc init.smdkc110.rc lib lpm.rc modules recovery.rc res sbin
do
  chown root.system /$blip
  chown root.system /$blip/*
done

chown root.system /lib/modules/*
chown root.system /res/images/*

# Enable init.d support
busybox run-parts /system/etc/init.d
sync

# remove bad su binaries/links
rm /system/bin/su
rm /system/xbin/su
rm /system/bin/jk-su
# my permissions bring all the root to the yard
chmod 06755 /sbin/su
# link it where apps want it
ln -s /sbin/su /system/bin/su
ln -s /sbin/su /system/xbin/su

# setup proper passwd and group files for 3rd party root access
if [ ! -f "/system/etc/passwd" ]; then
  echo "root::0:0:root:/data/local:/system/bin/sh" > /system/etc/passwd
  chmod 0666 /system/etc/passwd
fi
if [ ! -f "/system/etc/group" ]; then
  echo "root::0:" > /system/etc/group
  chmod 0666 /system/etc/group
fi

# patch to prevent certain malware apps
. > /system/bin/profile
chmod 644 /system/bin/profile

sync

mount -o remount,ro /dev/stl10 /system
mount -o remount,ro / /

