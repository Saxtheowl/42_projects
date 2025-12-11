#!/usr/bin/env bash
set -euo pipefail

# Prépare l'image disque et donne la procédure de mapping loop/mkfs/mount.
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WORK="${WORK:-$ROOT/work}"
IMG="${IMG:-$WORK/disk.raw}"
SIZE_MB="${SIZE_MB:-20480}"
SFDISK="${SFDISK:-$ROOT/configs/partitions.sfdisk}"
# Par défaut, utiliser un répertoire local pour éviter les permissions root-only.
LFS="${LFS:-$ROOT/.lfs}"

mkdir -p "$WORK"

if [ ! -f "$IMG" ]; then
	echo "[+] Création image ${IMG} (${SIZE_MB} MiB)"
	qemu-img create -f raw "$IMG" "${SIZE_MB}M"
else
	echo "[=] Image déjà présente : $IMG"
fi

if [ -f "$SFDISK" ]; then
	echo "[i] Partitionnement (à exécuter en root) :"
	echo "    sfdisk $IMG < $SFDISK"
else
	echo "[!] Fichier sfdisk manquant : $SFDISK"
fi

cat <<EOF
[i] Mapping loop (root requis) :
    LOOP=\$(losetup -Pf --show "$IMG")
    lsblk \$LOOP

[i] Création systèmes de fichiers :
    mkfs.vfat -F32 \${LOOP}p1
    mkswap \${LOOP}p2
    mkfs.ext4 \${LOOP}p3

[i] Montage :
    mkdir -p $LFS
    mount \${LOOP}p3 $LFS
    mkdir -p $LFS/boot
    mount \${LOOP}p1 $LFS/boot
    swapon \${LOOP}p2

[i] Variables LFS à exporter :
    export LFS=$LFS
    export LFS_TGT=x86_64-lfs-linux-gnu
    export PATH=\$LFS/tools/bin:/usr/bin
EOF
