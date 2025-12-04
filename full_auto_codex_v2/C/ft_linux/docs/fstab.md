# `/etc/fstab` exemple

Utiliser de préférence les UUID (`blkid`) à la place des `/dev/sdX` ci-dessous.

```
/dev/sda3  /      ext4    defaults        1 1
/dev/sda1  /boot  vfat    defaults        1 2
/dev/sda2  none   swap    sw              0 0
proc       /proc  proc    nosuid,noexec,nodev 0 0
sysfs      /sys   sysfs   nosuid,noexec,nodev 0 0
devpts     /dev/pts devpts gid=5,mode=620 0 0
tmpfs      /run   tmpfs   defaults        0 0
tmpfs      /tmp   tmpfs   mode=1777       0 0
```

Adaptez `root=/dev/sda3` et `/boot` selon votre partitionnement (UUID recommandé).
