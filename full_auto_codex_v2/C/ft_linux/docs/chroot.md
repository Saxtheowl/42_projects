# Entrer en chroot LFS

Pré-requis : partitions montées (root sur $LFS, /boot), `proc`/`sys`/`dev` bindés, toolchain installée.

```bash
export LFS=/mnt/lfs
scripts/chroot_prepare.sh mount

sudo chroot "$LFS" /usr/bin/env -i \
    HOME=/root TERM="$TERM" PS1='(lfs-chroot) \\u:\\w\\$ ' \
    PATH=/usr/bin:/usr/sbin \
    /bin/bash --login

scripts/chroot_prepare.sh umount
```

Alternative : `scripts/chroot_enter.sh` enchaîne mount -> chroot -> umount.

Dans le chroot, remettre `/etc/profile` au besoin (PATH + locale).
