#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="${IMG:-$ROOT/work/disk.raw}"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/image_report.txt"

mkdir -p "$REPORT_DIR"

{
	echo "Image report"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "image: $IMG"
	if [ -f "$IMG" ]; then
		echo "exists: yes"
		echo "size_bytes: $(stat -c%s "$IMG")"
		echo "size_human: $(du -h "$IMG" | awk '{print $1}')"
	else
		echo "exists: no"
	fi
	if command -v qemu-img >/dev/null 2>&1 && [ -f "$IMG" ]; then
		echo ""
		echo "qemu-img info:"
		qemu-img info "$IMG"
	fi
} >"$OUT"

echo "[OK] Image report generated: $OUT"
