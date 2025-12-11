#!/usr/bin/env bash
# Source this file to set up LFS environment variables for the toolchain/chroot.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# Par défaut, travailler dans un répertoire local accessible en user (évite /mnt/lfs root-only).
export LFS=${LFS:-$ROOT/.lfs}
export LFS_TGT=${LFS_TGT:-x86_64-lfs-linux-gnu}
export PATH=$LFS/tools/bin:/usr/bin:/bin
export LC_ALL=POSIX
export LFS_CFLAGS="-O2 -pipe"

if [ ! -d "$LFS" ]; then
	echo "[i] Création du répertoire LFS: $LFS"
	mkdir -p "$LFS"
fi
