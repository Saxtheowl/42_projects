#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_report.txt"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_report_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--out <file>]

Valide le rapport build_summary_alerts_stats_report.
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
	echo "build_summary_alerts_stats_report_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$REPORT_FILE" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "report missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for key in alerts_total bundle_score stats_result trend_avg_alerts trend_avg_score trend_warn trend_result alerts_delta score_delta delta_result rollup_entries rollup_window rollup_delta_alerts rollup_delta_score rollup_result rollup_score rollup_score_result result; do
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

echo "[OK] Build summary alerts stats report validate generated: $OUT_TXT"
