#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_rollup.md"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport Markdown pour le rollup historique des stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--out) OUT_MD="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$REPORT_FILE" ]; then
	{
		echo "# Build Summary Alerts Stats History Rollup"
		echo ""
		echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
		echo ""
		echo "Result: missing"
	} >"$OUT_MD"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$REPORT_FILE" | head -n 1 | awk '{print $2}'
}

entries=$(get_value "entries")
window=$(get_value "window")
prev_present=$(get_value "prev_present")
last_avg_alerts=$(get_value "last_avg_alerts")
last_avg_score=$(get_value "last_avg_score")
prev_avg_alerts=$(get_value "prev_avg_alerts")
prev_avg_score=$(get_value "prev_avg_score")
delta_alerts=$(get_value "delta_alerts")
delta_score=$(get_value "delta_score")
result=$(get_value "result")

entries="${entries:-0}"
window="${window:-0}"
prev_present="${prev_present:-0}"
last_avg_alerts="${last_avg_alerts:-0}"
last_avg_score="${last_avg_score:-0}"
prev_avg_alerts="${prev_avg_alerts:-0}"
prev_avg_score="${prev_avg_score:-0}"
delta_alerts="${delta_alerts:-0}"
delta_score="${delta_score:-0}"
result="${result:-unknown}"

{
	echo "# Build Summary Alerts Stats History Rollup"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Overview"
	echo "- entries: $entries"
	echo "- window: $window"
	echo "- prev_present: $prev_present"
	echo "- result: $result"
	echo ""
	echo "## Averages"
	echo "| scope | avg_alerts | avg_score |"
	echo "| --- | --- | --- |"
	echo "| last | $last_avg_alerts | $last_avg_score |"
	echo "| prev | $prev_avg_alerts | $prev_avg_score |"
	echo ""
	echo "## Delta"
	echo "- delta_alerts: $delta_alerts"
	echo "- delta_score: $delta_score"
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history rollup MD generated: $OUT_MD"
