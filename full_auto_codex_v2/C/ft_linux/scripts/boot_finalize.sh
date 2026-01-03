#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LFS="${LFS:-$ROOT/.lfs}"
DEVICE=""
TARGET="${TARGET:-i386-pc}"
EFI_DIR="${EFI_DIR:-$LFS/boot}"
ROOTDEV=""
SKIP_GRUB_INSTALL=0

usage() {
	cat <<EOF
Usage: $0 --device <disk> [--target <grub-target>] [--efi-dir <dir>] [--rootdev <dev>] [--lfs <dir>] [--skip-grub-install]

Runs: ensure_grub_cfg -> grub_install -> validate_grub_cfg -> boot_checklist -> boot_artifacts verify
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
		--rootdev)
			ROOTDEV="${2:-}"
			[ -n "$ROOTDEV" ] || usage
			shift 2
			;;
		--lfs)
			LFS="${2:-}"
			[ -n "$LFS" ] || usage
			shift 2
			;;
		--skip-grub-install)
			SKIP_GRUB_INSTALL=1
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

if [ -z "$DEVICE" ] && [ "$SKIP_GRUB_INSTALL" -eq 0 ]; then
	echo "[ERR] --device requis pour grub-install." >&2
	exit 1
fi

if [ -n "$ROOTDEV" ]; then
	"$ROOT/scripts/ensure_grub_cfg.sh" --lfs "$LFS" --rootdev "$ROOTDEV"
else
	"$ROOT/scripts/ensure_grub_cfg.sh" --lfs "$LFS"
fi

if [ "$SKIP_GRUB_INSTALL" -eq 0 ]; then
	"$ROOT/scripts/grub_install.sh" --lfs "$LFS" --device "$DEVICE" --target "$TARGET" --efi-dir "$EFI_DIR"
fi

REPORT_DIR="$ROOT/reports"
REPORT_OUT="$REPORT_DIR/boot_finalize.txt"
mkdir -p "$REPORT_DIR"

"$ROOT/scripts/validate_grub_cfg.sh" --lfs "$LFS" || true
"$ROOT/scripts/boot_checklist.sh" --lfs "$LFS" || true
"$ROOT/scripts/boot_artifacts.sh" verify --lfs "$LFS" || true
"$ROOT/scripts/export_boot_artifacts.sh" --lfs "$LFS" || true

{
	echo "Boot finalize report"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "device: ${DEVICE:-none}"
	echo "target: $TARGET"
	echo "lfs: $LFS"
	echo "grub_install: $( [ "$SKIP_GRUB_INSTALL" -eq 1 ] && echo skipped || echo attempted )"
} >"$REPORT_OUT"

echo "[OK] Boot finalization complete."
echo "[OK] Report: $REPORT_OUT"
