#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/sources"
CONFIG_DIR="$ROOT/configs"
VERSION="${KERNEL_VERSION:-6.6.54}"
PKG="linux-$VERSION"
TARGET_CFG="$CONFIG_DIR/linux-$VERSION.config"
APPLY_REQS=0

usage() {
	cat <<EOF
Usage: $0 [--version <ver>] [--out <file>] [--src <dir>] [--apply-reqs]

Generates a baseline kernel config using defconfig.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--version)
			VERSION="${2:-}"
			[ -n "$VERSION" ] || usage
			PKG="linux-$VERSION"
			shift 2
			;;
		--out)
			TARGET_CFG="${2:-}"
			[ -n "$TARGET_CFG" ] || usage
			shift 2
			;;
		--src)
			SRC="${2:-}"
			[ -n "$SRC" ] || usage
			shift 2
			;;
		--apply-reqs)
			APPLY_REQS=1
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

if [ ! -f "$SRC/$PKG.tar.xz" ]; then
	echo "[ERR] Tarball manquant: $SRC/$PKG.tar.xz" >&2
	exit 1
fi

BUILD_DIR="$ROOT/build/kernel-config-$VERSION"
mkdir -p "$BUILD_DIR"

cd "$BUILD_DIR"
[ -d "$PKG" ] || tar xf "$SRC/$PKG.tar.xz"
cd "$PKG"

make defconfig

mkdir -p "$(dirname "$TARGET_CFG")"
cp -f .config "$TARGET_CFG"
if [ "$APPLY_REQS" -eq 1 ]; then
	"$ROOT/scripts/apply_kernel_requirements.sh" --config "$TARGET_CFG"
fi
echo "[OK] Config generated: $TARGET_CFG"
