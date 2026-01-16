#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.md"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--out <file>]

Genere un rapport Markdown pour la synthese rollup.
EOF
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
		echo "# Build Summary Alerts Stats History Rollup Overview"
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

rollup_entries=$(get_value "rollup_entries")
rollup_window=$(get_value "rollup_window")
rollup_delta_alerts=$(get_value "rollup_delta_alerts")
rollup_delta_score=$(get_value "rollup_delta_score")
rollup_result=$(get_value "rollup_result")
rollup_score=$(get_value "rollup_score")
rollup_score_result=$(get_value "rollup_score_result")
rollup_bundle_validate=$(get_value "rollup_bundle_validate")
result=$(get_value "result")

rollup_entries="${rollup_entries:-0}"
rollup_window="${rollup_window:-0}"
rollup_delta_alerts="${rollup_delta_alerts:-0}"
rollup_delta_score="${rollup_delta_score:-0}"
rollup_result="${rollup_result:-unknown}"
rollup_score="${rollup_score:-0}"
rollup_score_result="${rollup_score_result:-unknown}"
rollup_bundle_validate="${rollup_bundle_validate:-unknown}"
result="${result:-unknown}"

{
	echo "# Build Summary Alerts Stats History Rollup Overview"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Rollup"
	echo "- entries: $rollup_entries"
	echo "- window: $rollup_window"
	echo "- delta_alerts: $rollup_delta_alerts"
	echo "- delta_score: $rollup_delta_score"
	echo "- result: $rollup_result"
	echo ""
	echo "## Score"
	echo "- score: $rollup_score"
	echo "- result: $rollup_score_result"
	echo ""
	echo "## Bundle"
	echo "- validate: $rollup_bundle_validate"
	echo ""
	echo "Result: $result"
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history rollup overview MD generated: $OUT_MD"
