#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_items_report.txt"
OUT_TXT="$REPORT_DIR/build_summary_alerts_items_report_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--out <file>]

Valide la presence des lignes cles dans build_summary_alerts_items_report.txt.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
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
	echo "build_summary_alerts_items_report_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$REPORT_FILE" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "report missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
if grep -q "^result: missing_inputs" "$REPORT_FILE"; then
	echo "result: warn" >>"$OUT_TXT"
	echo "missing_inputs: true" >>"$OUT_TXT"
	exit 0
fi

for key in items_total items_unique items_mode items_top trend_avg_total trend_avg_unique trend_warn trend_result delta_total delta_unique delta_result delta_top_changed delta_mode_changed result; do
	if ! grep -q "^${key}:" "$REPORT_FILE"; then
		echo "missing_line: $key" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts items report validate generated: $OUT_TXT"
