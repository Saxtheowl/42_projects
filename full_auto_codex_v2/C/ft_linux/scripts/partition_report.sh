#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SFDISK="${SFDISK:-$ROOT/configs/partitions.sfdisk}"
IMG="${IMG:-}"
REPORT_DIR="$ROOT/reports"
REPORT_TXT="$REPORT_DIR/partition_report.txt"
REPORT_CSV="$REPORT_DIR/partition_report.csv"

usage() {
	cat <<EOF
Usage: $0 [--sfdisk <file>] [--img <file>]

Generates a report from partitions.sfdisk; optionally compares with image layout.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--sfdisk)
			SFDISK="${2:-}"
			[ -n "$SFDISK" ] || usage
			shift 2
			;;
		--img)
			IMG="${2:-}"
			[ -n "$IMG" ] || usage
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

if [ ! -f "$SFDISK" ]; then
	echo "[ERR] Fichier sfdisk introuvable: $SFDISK" >&2
	exit 1
fi

label=$(awk -F': ' '/^label:/{print $2; exit}' "$SFDISK")
unit=$(awk -F': ' '/^unit:/{print $2; exit}' "$SFDISK")

{
	echo "Partition report"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "sfdisk: $SFDISK"
	[ -n "$label" ] && echo "label: $label"
	[ -n "$unit" ] && echo "unit: $unit"
	echo ""
	echo "Partitions:"
	awk -F: '/^label:/ || /^unit:/ || /^device:/ {next} /^[^#].*start=/ {print "- " $0}' "$SFDISK"
	echo ""
	if [ -n "$IMG" ]; then
		if command -v sfdisk >/dev/null 2>&1 && [ -f "$IMG" ]; then
			echo "Image layout:"
			sfdisk -d "$IMG" 2>/dev/null | sed -n '/^#\|^label:\|^unit:\|^device:/!p'
		else
			echo "Image layout: unavailable"
		fi
	fi
} >"$REPORT_TXT"

{
	echo "partition,detail"
	awk -F: '/^label:/ || /^unit:/ || /^device:/ {next} /^[^#].*start=/ {printf "%d,%s\n", NR, $0}' "$SFDISK"
} >"$REPORT_CSV"

echo "[OK] Partition report generated: $REPORT_TXT"
