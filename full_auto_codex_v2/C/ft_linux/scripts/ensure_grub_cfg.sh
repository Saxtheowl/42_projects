#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
FSTAB="${FSTAB:-$LFS/etc/fstab}"
TITLE="${TITLE:-ft_linux}"
ROOTDEV="${ROOTDEV:-}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--boot <dir>] [--fstab <file>] [--title <name>] [--rootdev <dev>]

Generates grub.cfg via scripts/generate_grub_cfg.sh and installs it to $BOOT_DIR/grub/grub.cfg.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--boot)
			BOOT_DIR="${2:-}"
			[ -n "$BOOT_DIR" ] || usage
			shift 2
			;;
		--fstab)
			FSTAB="${2:-}"
			[ -n "$FSTAB" ] || usage
			shift 2
			;;
		--title)
			TITLE="${2:-}"
			[ -n "$TITLE" ] || usage
			shift 2
			;;
		--rootdev)
			ROOTDEV="${2:-}"
			[ -n "$ROOTDEV" ] || usage
			shift 2
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

TMP_CFG="$ROOT/configs/grub.cfg.generated"

mkdir -p "$BOOT_DIR/grub"

if [ -n "$ROOTDEV" ]; then
	"$ROOT/scripts/generate_grub_cfg.sh" --lfs "$LFS" --boot "$BOOT_DIR" --fstab "$FSTAB" --output "$TMP_CFG" --title "$TITLE" --rootdev "$ROOTDEV"
else
	"$ROOT/scripts/generate_grub_cfg.sh" --lfs "$LFS" --boot "$BOOT_DIR" --fstab "$FSTAB" --output "$TMP_CFG" --title "$TITLE"
fi

cp -f "$TMP_CFG" "$BOOT_DIR/grub/grub.cfg"
echo "[OK] Installed grub.cfg to $BOOT_DIR/grub/grub.cfg"
