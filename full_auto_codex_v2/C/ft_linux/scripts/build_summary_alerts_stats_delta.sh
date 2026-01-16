#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_delta.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats_delta.json"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--json <file>]

Compare les deux dernieres entrees stats alertes.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) HISTORY_CSV="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_delta generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $HISTORY_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

line_count=$(tail -n +2 "$HISTORY_CSV" | wc -l | tr -d ' ')
if [ "$line_count" -lt 1 ]; then
	echo "result: empty_csv" >>"$OUT_TXT"
	exit 0
fi

last_line=$(tail -n 1 "$HISTORY_CSV")
prev_line=""
if [ "$line_count" -ge 2 ]; then
	prev_line=$(tail -n 2 "$HISTORY_CSV" | head -n 1)
fi

last_generated=$(printf '%s' "$last_line" | awk -F',' '{print $1}')
last_alerts=$(printf '%s' "$last_line" | awk -F',' '{print $2}')
last_score=$(printf '%s' "$last_line" | awk -F',' '{print $3}')
last_result=$(printf '%s' "$last_line" | awk -F',' '{print $4}')

prev_generated=""
prev_alerts="0"
prev_score="0"
if [ -n "$prev_line" ]; then
	prev_generated=$(printf '%s' "$prev_line" | awk -F',' '{print $1}')
	prev_alerts=$(printf '%s' "$prev_line" | awk -F',' '{print $2}')
	prev_score=$(printf '%s' "$prev_line" | awk -F',' '{print $3}')
fi

last_alerts="${last_alerts:-0}"
prev_alerts="${prev_alerts:-0}"
last_score="${last_score:-0}"
prev_score="${prev_score:-0}"

alerts_delta=$((last_alerts - prev_alerts))
score_delta=$((last_score - prev_score))

result="ok"
if [ "$alerts_delta" -gt 0 ] || [ "$last_result" != "ok" ]; then
	result="warn"
fi

{
	echo "last_generated: $last_generated"
	echo "last_alerts: $last_alerts"
	echo "last_score: $last_score"
	echo "last_result: ${last_result:-unknown}"
	echo "prev_generated: $prev_generated"
	echo "prev_alerts: $prev_alerts"
	echo "prev_score: $prev_score"
	echo "alerts_delta: $alerts_delta"
	echo "score_delta: $score_delta"
	echo "result: $result"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"last\": {"
	echo "    \"generated\": \"$last_generated\","
	echo "    \"alerts\": $last_alerts,"
	echo "    \"bundle_score\": $last_score,"
	echo "    \"result\": \"${last_result:-unknown}\""
	echo "  },"
	echo "  \"previous\": {"
	echo "    \"generated\": \"$prev_generated\","
	echo "    \"alerts\": $prev_alerts,"
	echo "    \"bundle_score\": $prev_score"
	echo "  },"
	echo "  \"alerts_delta\": $alerts_delta,"
	echo "  \"score_delta\": $score_delta,"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats delta generated: $OUT_TXT"
