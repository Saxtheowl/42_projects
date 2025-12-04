#!/usr/bin/env bash
# Helper to mount bind points and enter the LFS chroot.
set -euo pipefail

LFS=${LFS:-/mnt/lfs}

if [ ! -d "$LFS" ]; then
	echo "[!] LFS directory not found: $LFS" >&2
	exit 1
fi

mountpoint -q "$LFS/dev" || sudo mount -v --bind /dev "$LFS/dev"
mountpoint -q "$LFS/dev/pts" || sudo mount -vt devpts devpts "$LFS/dev/pts" -o gid=5,mode=620
mountpoint -q "$LFS/proc" || sudo mount -vt proc proc "$LFS/proc"
mountpoint -q "$LFS/sys" || sudo mount -vt sysfs sysfs "$LFS/sys"
mountpoint -q "$LFS/run" || sudo mount -vt tmpfs tmpfs "$LFS/run"

exec sudo chroot "$LFS" /usr/bin/env -i \
	HOME=/root TERM="$TERM" PS1='(lfs-chroot) \u:\w\$ ' \
	PATH=/usr/bin:/usr/sbin \
	/bin/bash --login
