#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
FSTAB="${FSTAB:-$LFS/etc/fstab}"
OUTPUT="${OUTPUT:-$ROOT/configs/grub.cfg.generated}"
TITLE="${TITLE:-ft_linux}"
ROOTDEV=""
INITRD=""

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--boot <dir>] [--fstab <file>] [--output <file>] [--title <name>] [--rootdev <dev>] [--initrd <path>]

Options:
  --lfs <dir>      Racine cible (default: $LFS)
  --boot <dir>     Repertoire boot (default: $BOOT_DIR)
  --fstab <file>   Fichier fstab pour extraire le root UUID (default: $FSTAB)
  --output <file>  Fichier grub.cfg genere (default: $OUTPUT)
  --title <name>   Titre entree menu (default: $TITLE)
  --rootdev <dev>  Override root device (ex: /dev/sda3) si pas d'UUID
  --initrd <path>  Initramfs a charger (par defaut: auto)
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
		--output)
			OUTPUT="${2:-}"
			[ -n "$OUTPUT" ] || usage
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
		--initrd)
			INITRD="${2:-}"
			[ -n "$INITRD" ] || usage
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

if [ ! -d "$BOOT_DIR" ]; then
	echo "[ERR] Boot dir introuvable: $BOOT_DIR" >&2
	exit 1
fi

VMLINUX=$(ls -1 "$BOOT_DIR"/vmlinuz-*-ftlinux 2>/dev/null | sort | tail -n 1 || true)
if [ -z "$VMLINUX" ]; then
	echo "[ERR] Aucun kernel vmlinuz-*-ftlinux dans $BOOT_DIR" >&2
	exit 1
fi

if [ -z "$INITRD" ]; then
	INITRD=$(ls -1 "$BOOT_DIR"/initramfs-*-ftlinux.img 2>/dev/null | sort | tail -n 1 || true)
fi

ROOT_UUID=""
if [ -f "$FSTAB" ]; then
	ROOT_UUID=$(awk '$2 == "/" && $1 ~ /^UUID=/ {sub(/^UUID=/, "", $1); print $1; exit}' "$FSTAB")
fi

ROOT_ARG=""
if [ -n "$ROOT_UUID" ]; then
	ROOT_ARG="root=UUID=$ROOT_UUID"
elif [ -n "$ROOTDEV" ]; then
	ROOT_ARG="root=$ROOTDEV"
else
	echo "[ERR] Impossible de determiner le root (fstab sans UUID). Utilisez --rootdev." >&2
	exit 1
fi

cat >"$OUTPUT" <<EOF
set timeout=5
set default=0

menuentry "$TITLE" {
    linux /$(basename "$BOOT_DIR")/$(basename "$VMLINUX") $ROOT_ARG ro
EOF

if [ -n "$INITRD" ]; then
	cat >>"$OUTPUT" <<EOF
    initrd /$(basename "$BOOT_DIR")/$(basename "$INITRD")
EOF
fi
echo "}" >>"$OUTPUT"

echo "[OK] grub.cfg genere: $OUTPUT"
