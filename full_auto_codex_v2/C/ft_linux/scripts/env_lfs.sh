#!/usr/bin/env bash
# Source this file to set up LFS environment variables for the toolchain/chroot.
export LFS=${LFS:-/mnt/lfs}
export LFS_TGT=${LFS_TGT:-x86_64-lfs-linux-gnu}
export PATH=$LFS/tools/bin:/usr/bin:/bin
export LC_ALL=POSIX
export LFS_CFLAGS="-O2 -pipe"

if [ ! -d "$LFS" ]; then
	echo "[!] LFS directory not found: $LFS" >&2
fi
