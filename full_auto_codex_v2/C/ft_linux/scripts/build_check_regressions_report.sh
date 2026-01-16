#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_MD="$REPORT_DIR/build_check_regressions_report.md"
SUMMARY_TXT="$REPORT_DIR/build_check_regressions_summary.txt"
TOP_TXT="$REPORT_DIR/build_check_regressions_top.txt"
TREND_TXT="$REPORT_DIR/build_check_regressions_trend.txt"
GROUPS_TXT="$REPORT_DIR/build_check_regressions_groups.txt"
EXPORT_CSV="$REPORT_DIR/build_check_regressions_export.csv"
INDEX_JSON="$REPORT_DIR/build_check_regressions_index.json"

usage() {
	cat <<EOF
Usage: $0 [--out <file>]

Genere un rapport Markdown des regressions checks.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--out) OUT_MD="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "# build_check regressions report"
	echo ""
	echo "generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Summary"
	if [ -f "$SUMMARY_TXT" ]; then
		grep -E '^(regressions|recoveries|total_compared|worst_group|worst_rate|last_pair|last_regressions|result):' "$SUMMARY_TXT"
	else
		echo "_missing: $SUMMARY_TXT_"
	fi
	echo ""
	echo "## Top groups (rate/count)"
	if [ -f "$TOP_TXT" ]; then
		sed -n '1,80p' "$TOP_TXT"
	else
		echo "_missing: $TOP_TXT_"
	fi
	echo ""
	echo "## Trend (pairs)"
	if [ -f "$TREND_TXT" ]; then
		sed -n '1,120p' "$TREND_TXT"
	else
		echo "_missing: $TREND_TXT_"
	fi
	echo ""
	echo "## Groups"
	if [ -f "$GROUPS_TXT" ]; then
		sed -n '1,160p' "$GROUPS_TXT"
	else
		echo "_missing: $GROUPS_TXT_"
	fi
	echo ""
	echo "## Exports"
	echo "- csv: $EXPORT_CSV"
	echo "- index: $INDEX_JSON"
} >"$OUT_MD"

echo "[OK] Build check regressions report generated: $OUT_MD"
