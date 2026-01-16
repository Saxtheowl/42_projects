#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_report.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_report.md"

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport Markdown pour l'historique stats alertes.
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
		echo "# Build Summary Alerts Stats History"
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
last_date=$(get_value "last_date")
last_alerts=$(get_value "last_alerts_total")
last_score=$(get_value "last_bundle_score")
last_result=$(get_value "last_result")
alerts_min=$(get_value "alerts_total_min")
alerts_max=$(get_value "alerts_total_max")
alerts_avg=$(get_value "alerts_total_avg")
score_min=$(get_value "bundle_score_min")
score_max=$(get_value "bundle_score_max")
score_avg=$(get_value "bundle_score_avg")
ok_count=$(get_value "result_ok")
warn_count=$(get_value "result_warn")
unknown_count=$(get_value "result_unknown")
other_count=$(get_value "result_other")
result=$(get_value "result")

entries="${entries:-0}"
last_date="${last_date:-unknown}"
last_alerts="${last_alerts:-0}"
last_score="${last_score:-0}"
last_result="${last_result:-unknown}"
alerts_min="${alerts_min:-0}"
alerts_max="${alerts_max:-0}"
alerts_avg="${alerts_avg:-0}"
score_min="${score_min:-0}"
score_max="${score_max:-0}"
score_avg="${score_avg:-0}"
ok_count="${ok_count:-0}"
warn_count="${warn_count:-0}"
unknown_count="${unknown_count:-0}"
other_count="${other_count:-0}"
result="${result:-unknown}"

{
	echo "# Build Summary Alerts Stats History"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Overview"
	echo "- entries: $entries"
	echo "- result: $result"
	echo ""
	echo "## Last Entry"
	echo "- date: $last_date"
	echo "- alerts_total: $last_alerts"
	echo "- bundle_score: $last_score"
	echo "- result: $last_result"
	echo ""
	echo "## Alerts Total"
	echo "- min: $alerts_min"
	echo "- max: $alerts_max"
	echo "- avg: $alerts_avg"
	echo ""
	echo "## Bundle Score"
	echo "- min: $score_min"
	echo "- max: $score_max"
	echo "- avg: $score_avg"
	echo ""
	echo "## Results"
	echo "- ok: $ok_count"
	echo "- warn: $warn_count"
	echo "- unknown: $unknown_count"
	echo "- other: $other_count"
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history report MD generated: $OUT_MD"
