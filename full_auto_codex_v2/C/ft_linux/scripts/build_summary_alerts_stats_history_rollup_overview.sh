#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
ROLLUP_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
ROLLUP_SCORE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
BUNDLE_VALIDATE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle_validate.txt"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.json"

usage() {
	cat <<EOF
Usage: $0 [--rollup <file>] [--score <file>] [--bundle-validate <file>] [--out <file>] [--json <file>]

Genere une synthese rollup historique (rollup + score + bundle).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--rollup) ROLLUP_FILE="$2"; shift 2 ;;
		--score) ROLLUP_SCORE_FILE="$2"; shift 2 ;;
		--bundle-validate) BUNDLE_VALIDATE_FILE="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_rollup_overview generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "rollup: $ROLLUP_FILE"
	echo "score: $ROLLUP_SCORE_FILE"
	echo "bundle_validate: $BUNDLE_VALIDATE_FILE"
	echo ""
} >"$OUT_TXT"

get_value() {
	local file="$1" key="$2"
	grep -E "^${key}:" "$file" | head -n 1 | awk '{print $2}'
}

rollup_entries="0"
rollup_window="0"
rollup_delta_alerts="0"
rollup_delta_score="0"
rollup_result="missing"
if [ -f "$ROLLUP_FILE" ]; then
	rollup_entries=$(get_value "$ROLLUP_FILE" "entries")
	rollup_window=$(get_value "$ROLLUP_FILE" "window")
	rollup_delta_alerts=$(get_value "$ROLLUP_FILE" "delta_alerts")
	rollup_delta_score=$(get_value "$ROLLUP_FILE" "delta_score")
	rollup_result=$(get_value "$ROLLUP_FILE" "result")
fi

rollup_score="0"
rollup_score_result="missing"
if [ -f "$ROLLUP_SCORE_FILE" ]; then
	rollup_score=$(get_value "$ROLLUP_SCORE_FILE" "score")
	rollup_score_result=$(get_value "$ROLLUP_SCORE_FILE" "result")
fi

bundle_validate="missing"
if [ -f "$BUNDLE_VALIDATE_FILE" ]; then
	bundle_validate=$(get_value "$BUNDLE_VALIDATE_FILE" "result")
fi

rollup_entries="${rollup_entries:-0}"
rollup_window="${rollup_window:-0}"
rollup_delta_alerts="${rollup_delta_alerts:-0}"
rollup_delta_score="${rollup_delta_score:-0}"
rollup_result="${rollup_result:-missing}"
rollup_score="${rollup_score:-0}"
rollup_score_result="${rollup_score_result:-missing}"
bundle_validate="${bundle_validate:-missing}"

result="ok"
if [ "$rollup_result" != "ok" ] || [ "$rollup_score_result" != "ok" ] || [ "$bundle_validate" != "ok" ]; then
	result="warn"
fi

{
	echo "rollup_entries: $rollup_entries"
	echo "rollup_window: $rollup_window"
	echo "rollup_delta_alerts: $rollup_delta_alerts"
	echo "rollup_delta_score: $rollup_delta_score"
	echo "rollup_result: $rollup_result"
	echo "rollup_score: $rollup_score"
	echo "rollup_score_result: $rollup_score_result"
	echo "rollup_bundle_validate: $bundle_validate"
	echo "result: $result"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"rollup\": {"
	echo "    \"entries\": $rollup_entries,"
	echo "    \"window\": $rollup_window,"
	echo "    \"delta_alerts\": $rollup_delta_alerts,"
	echo "    \"delta_score\": $rollup_delta_score,"
	echo "    \"result\": \"$rollup_result\""
	echo "  },"
	echo "  \"score\": {"
	echo "    \"value\": $rollup_score,"
	echo "    \"result\": \"$rollup_score_result\""
	echo "  },"
	echo "  \"bundle_validate\": \"$bundle_validate\","
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats history rollup overview generated: $OUT_TXT"
