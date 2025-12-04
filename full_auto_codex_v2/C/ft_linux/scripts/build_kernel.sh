#!/usr/bin/env bash
set -euo pipefail

# Squelette de compilation du kernel dans le chroot LFS.
# Prérequis : tarball linux-6.6.54 présent dans sources/, montages LFS actifs.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"
BUILD="$ROOT/build/kernel"
VERSION="${KERNEL_VERSION:-6.6.54}"
PKG="linux-$VERSION"
JOBS="${JOBS:-$(nproc)}"

mkdir -p "$BUILD"

cd "$BUILD"
if [ ! -d "$PKG" ]; then
	tar -xf "$SRC/$PKG.tar.xz"
fi
cd "$PKG"

if [ ! -f .config ]; then
	echo "[i] Copiez/ajustez un .config (ex: configs/linux-6.6.config) puis relancez."
	exit 0
fi

make olddefconfig
make -j"$JOBS"
make modules_install
cp -v arch/x86/boot/bzImage /boot/vmlinuz-$VERSION-ftlinux
cp -v System.map /boot/System.map-$VERSION
cp -v .config /boot/config-$VERSION

echo "[i] Kernel installé sous /boot. Pensez à régénérer grub.cfg."
