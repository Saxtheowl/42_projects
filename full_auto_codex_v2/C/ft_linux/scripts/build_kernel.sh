#!/usr/bin/env bash
set -euo pipefail

# Build du kernel (chroot ou host vers $LFS).
# Prérequis : tarball linux-6.6.54 présent dans sources/, montages LFS actifs.

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"
BUILD="$ROOT/build/kernel"
LOGDIR="$ROOT/logs/kernel"
VERSION="${KERNEL_VERSION:-6.6.54}"
PKG="linux-$VERSION"
JOBS="${JOBS:-$(nproc)}"
CONFIG_SRC=""
PRINT_RELEASE=0
CLEAN=0
NO_MODULES=0
NO_INSTALL=0

usage() {
	cat <<EOF
Usage: $0 [--config <path>] [--clean] [--no-modules] [--no-install] [--print-release]

Options:
  --config <path>  Fournit un .config a copier avant build.
  --clean          Supprime le dossier de build courant.
  --no-modules     Ne pas installer les modules.
  --no-install     Ne pas copier bzImage/System.map/config vers /boot.
  --print-release  Affiche la version kernel (make kernelrelease) et quitte.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--config)
			CONFIG_SRC="${2:-}"
			[ -n "$CONFIG_SRC" ] || usage
			shift 2
			;;
		--clean)
			CLEAN=1
			shift
			;;
		--no-modules)
			NO_MODULES=1
			shift
			;;
		--no-install)
			NO_INSTALL=1
			shift
			;;
		--print-release)
			PRINT_RELEASE=1
			shift
			;;
		-h|--help)
			usage
			;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$BUILD" "$LOGDIR"

if [ "$CLEAN" -eq 1 ]; then
	rm -rf "$BUILD/$PKG"
fi

if [ ! -f "$SRC/$PKG.tar.xz" ]; then
	echo "[ERR] Tarball manquant: $SRC/$PKG.tar.xz" >&2
	exit 1
fi

cd "$BUILD"
if [ ! -d "$PKG" ]; then
	tar -xf "$SRC/$PKG.tar.xz"
fi
cd "$PKG"

if [ -n "$CONFIG_SRC" ]; then
	if [ ! -f "$CONFIG_SRC" ]; then
		echo "[ERR] Config manquante: $CONFIG_SRC" >&2
		exit 1
	fi
	cp -v "$CONFIG_SRC" .config
fi

if [ ! -f .config ]; then
	echo "[i] Copiez/ajustez un .config (ex: configs/linux-6.6.config.todo) puis relancez."
	exit 0
fi

if [ "$PRINT_RELEASE" -eq 1 ]; then
	make kernelrelease
	exit 0
fi

in_chroot=0
if [ -d /proc/1/root ]; then
	if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
		in_chroot=1
	fi
fi

if [ "$in_chroot" -eq 1 ]; then
	DESTROOT="/"
else
	DESTROOT="${LFS:-$ROOT/.lfs}"
fi

if [ ! -d "$DESTROOT" ]; then
	echo "[ERR] Destination root introuvable: $DESTROOT" >&2
	exit 1
fi

BOOT_DIR="${BOOT_DIR:-$DESTROOT/boot}"
mkdir -p "$BOOT_DIR"

make olddefconfig >"$LOGDIR/kernel.config.log" 2>&1
make -j"$JOBS" >"$LOGDIR/kernel.make.log" 2>&1

if [ "$NO_MODULES" -eq 0 ]; then
	make modules_install INSTALL_MOD_PATH="$DESTROOT" >"$LOGDIR/kernel.modules.log" 2>&1
fi

if [ "$NO_INSTALL" -eq 0 ]; then
	cp -v arch/x86/boot/bzImage "$BOOT_DIR/vmlinuz-$VERSION-ftlinux"
	cp -v System.map "$BOOT_DIR/System.map-$VERSION"
	cp -v .config "$BOOT_DIR/config-$VERSION"
fi

echo "[i] Kernel prêt sous $BOOT_DIR. Pensez à régénérer grub.cfg."
