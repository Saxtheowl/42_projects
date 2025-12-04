# Entrer en chroot LFS

Pré-requis : partitions montées (root sur $LFS, /boot), `proc`/`sys`/`dev` bindés, toolchain installée.

```bash
export LFS=/mnt/lfs
sudo mount -v --bind /dev $LFS/dev
sudo mount -vt devpts devpts $LFS/dev/pts -o gid=5,mode=620
sudo mount -vt proc proc $LFS/proc
sudo mount -vt sysfs sysfs $LFS/sys
sudo mount -vt tmpfs tmpfs $LFS/run

sudo chroot "$LFS" /usr/bin/env -i \
    HOME=/root TERM="$TERM" PS1='(lfs-chroot) \\u:\\w\\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash --login
```

Dans le chroot, remettre `/etc/profile` au besoin (PATH + locale).
