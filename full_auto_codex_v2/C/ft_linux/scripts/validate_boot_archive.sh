#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ARCHIVE="${ARCHIVE:-$ROOT/work/boot_artifacts.tar.gz}"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/boot_archive_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--archive <file>] [--out <file>]

Validates boot_artifacts archive contents.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--archive)
			ARCHIVE="${2:-}"
			[ -n "$ARCHIVE" ] || usage
			shift 2
			;;
		--out)
			OUT="${2:-}"
			[ -n "$OUT" ] || usage
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

mkdir -p "$REPORT_DIR"

if [ ! -f "$ARCHIVE" ]; then
	echo "[ERR] Archive introuvable: $ARCHIVE" >&2
	exit 1
fi

missing=0
{
	echo "Boot archive report"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "archive: $ARCHIVE"
	echo ""
	if tar -tzf "$ARCHIVE" >/dev/null 2>&1; then
		tar -tzf "$ARCHIVE" | grep -E '^vmlinuz-.*-ftlinux$' >/dev/null 2>&1 || { echo "[MISS] kernel"; missing=$((missing + 1)); }
		tar -tzf "$ARCHIVE" | grep -E '^initramfs-.*-ftlinux\.img$' >/dev/null 2>&1 || { echo "[MISS] initramfs"; missing=$((missing + 1)); }
		tar -tzf "$ARCHIVE" | grep -E '^grub/grub\.cfg$' >/dev/null 2>&1 || { echo "[MISS] grub.cfg"; missing=$((missing + 1)); }
	else
		echo "[ERR] Archive illisible"
		missing=$((missing + 1))
	fi
	echo ""
	if [ "$missing" -eq 0 ]; then
		echo "result: OK"
	else
		echo "result: MISSING ($missing)"
	fi
} >"$OUT"

echo "[OK] Boot archive report: $OUT"
