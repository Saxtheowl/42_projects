#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
MD_FILE="$REPORT_DIR/build_summary_alerts_items_report.md"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items_report_md_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--md <file>] [--out <file>]

Valide la presence des sections dans build_summary_alerts_items_report.md.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--md) MD_FILE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_items_report_md_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "md: $MD_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$MD_FILE" ]; then
	echo "result: missing_md" >>"$OUT_TXT"
	echo "md missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for header in "# Build summary alerts items report" "## Snapshot" "## Trend" "## Delta" "## Result"; do
	if ! grep -q "^${header}$" "$MD_FILE"; then
		echo "missing_header: $header" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts items report MD validate generated: $OUT_TXT"
