#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
DEVICE=""
TARGET="${TARGET:-i386-pc}"
EFI_DIR="${EFI_DIR:-$LFS/boot}"

usage() {
	cat <<EOF
Usage: $0 --device <disk> [--target <grub-target>] [--efi-dir <dir>] [--lfs <dir>]

Examples:
  $0 --device /dev/loop0 --target i386-pc
  $0 --device /dev/sda --target x86_64-efi --efi-dir /boot
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--device)
			DEVICE="${2:-}"
			[ -n "$DEVICE" ] || usage
			shift 2
			;;
		--target)
			TARGET="${2:-}"
			[ -n "$TARGET" ] || usage
			shift 2
			;;
		--efi-dir)
			EFI_DIR="${2:-}"
			[ -n "$EFI_DIR" ] || usage
			shift 2
			;;
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
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

if [ -z "$DEVICE" ]; then
	usage
fi

if [ "$(id -u)" -ne 0 ]; then
	echo "[ERR] Action requires root." >&2
	exit 1
fi

command -v grub-install >/dev/null 2>&1 || {
	echo "[ERR] grub-install not found." >&2
	exit 1
}

if [ ! -d "$LFS" ]; then
	echo "[ERR] LFS introuvable: $LFS" >&2
	exit 1
fi

if [ ! -d "$LFS/boot" ]; then
	echo "[ERR] /boot introuvable sous $LFS" >&2
	exit 1
fi

if [ "$TARGET" = "x86_64-efi" ]; then
	GRUB_CMD=(grub-install --target="$TARGET" --efi-directory="$EFI_DIR" --boot-directory="$LFS/boot" --removable --recheck "$DEVICE")
else
	GRUB_CMD=(grub-install --target="$TARGET" --boot-directory="$LFS/boot" --recheck "$DEVICE")
fi

echo "[i] Running: ${GRUB_CMD[*]}"
chroot "$LFS" /usr/bin/env -i \
	HOME=/root TERM="$TERM" PATH=/usr/bin:/usr/sbin:/bin:/sbin \
	"${GRUB_CMD[@]}"

echo "[OK] GRUB installed on $DEVICE ($TARGET)"
