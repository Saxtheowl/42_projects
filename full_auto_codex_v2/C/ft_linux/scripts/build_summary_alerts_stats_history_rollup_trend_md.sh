#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.md"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport Markdown pour la tendance rollup historique.
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
		echo "# Build Summary Alerts Stats History Rollup Trend"
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
avg_delta_alerts=$(get_value "avg_delta_alerts")
avg_delta_score=$(get_value "avg_delta_score")
avg_score=$(get_value "avg_score")
warn_rollup=$(get_value "warn_rollup")
warn_score=$(get_value "warn_score")
result=$(get_value "result")

entries="${entries:-0}"
avg_delta_alerts="${avg_delta_alerts:-0}"
avg_delta_score="${avg_delta_score:-0}"
avg_score="${avg_score:-0}"
warn_rollup="${warn_rollup:-0}"
warn_score="${warn_score:-0}"
result="${result:-unknown}"

{
	echo "# Build Summary Alerts Stats History Rollup Trend"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Overview"
	echo "- entries: $entries"
	echo "- result: $result"
	echo ""
	echo "## Averages"
	echo "| avg_delta_alerts | avg_delta_score | avg_score |"
	echo "| --- | --- | --- |"
	echo "| $avg_delta_alerts | $avg_delta_score | $avg_score |"
	echo ""
	echo "## Warnings"
	echo "| warn_rollup | warn_score |"
	echo "| --- | --- |"
	echo "| $warn_rollup | $warn_score |"
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history rollup trend MD generated: $OUT_MD"
