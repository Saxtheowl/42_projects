#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
BOOT_DIR="${BOOT_DIR:-$LFS/boot}"
OUT="${OUT:-$ROOT/work/boot_artifacts.tar.gz}"
CHECKSUM="${CHECKSUM:-$ROOT/checksums/boot_artifacts.sha256}"

usage() {
	cat <<EOF
Usage: $0 [--lfs <dir>] [--boot <dir>] [--out <file>] [--checksum <file>]

Packages /boot artifacts (kernel, initramfs, grub.cfg) into a tar.gz.
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
		--out)
			OUT="${2:-}"
			[ -n "$OUT" ] || usage
			shift 2
			;;
		--checksum)
			CHECKSUM="${2:-}"
			[ -n "$CHECKSUM" ] || usage
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

VMLINUX=$(ls -1 "$BOOT_DIR"/vmlinuz-*-ftlinux 2>/dev/null | head -n 1 || true)
INITRAMFS=$(ls -1 "$BOOT_DIR"/initramfs-*-ftlinux.img 2>/dev/null | head -n 1 || true)
GRUB_CFG="$BOOT_DIR/grub/grub.cfg"

if [ -z "$VMLINUX" ] || [ -z "$INITRAMFS" ] || [ ! -f "$GRUB_CFG" ]; then
	echo "[ERR] Missing boot artifacts (kernel/initramfs/grub.cfg)." >&2
	exit 1
fi

mkdir -p "$(dirname "$OUT")" "$(dirname "$CHECKSUM")"

tar -czf "$OUT" -C "$BOOT_DIR" \
	"$(basename "$VMLINUX")" \
	"$(basename "$INITRAMFS")" \
	"grub/grub.cfg"

if command -v sha256sum >/dev/null 2>&1; then
	sha256sum "$OUT" >"$CHECKSUM"
	echo "[OK] Boot artifacts packaged: $OUT"
	echo "[OK] Checksum written: $CHECKSUM"
else
	echo "[WARN] sha256sum not available; skipped checksum." >&2
	echo "[OK] Boot artifacts packaged: $OUT"
fi
