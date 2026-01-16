#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.md"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport Markdown pour le score rollup historique.
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
		echo "# Build Summary Alerts Stats History Rollup Score"
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
delta_alerts=$(get_value "delta_alerts")
delta_score=$(get_value "delta_score")
score=$(get_value "score")
result=$(get_value "result")

entries="${entries:-0}"
window="${window:-0}"
delta_alerts="${delta_alerts:-0}"
delta_score="${delta_score:-0}"
score="${score:-0}"
result="${result:-unknown}"

{
	echo "# Build Summary Alerts Stats History Rollup Score"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Overview"
	echo "- entries: $entries"
	echo "- window: $window"
	echo "- score: $score"
	echo "- result: $result"
	echo ""
	echo "## Deltas"
	echo "| delta_alerts | delta_score |"
	echo "| --- | --- |"
	echo "| $delta_alerts | $delta_score |"
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history rollup score MD generated: $OUT_MD"
