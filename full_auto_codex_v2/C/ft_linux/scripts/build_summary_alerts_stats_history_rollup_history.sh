#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
ROLLUP_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
ROLLUP_SCORE_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_score.txt"
OUT_CSV="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.txt"

usage() {
	cat <<EOF
Usage: $0 [--rollup <file>] [--score <file>] [--out <csv>] [--report <file>]

Ajoute une entree historique pour le rollup stats alertes.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--rollup) ROLLUP_FILE="$2"; shift 2 ;;
		--score) ROLLUP_SCORE_FILE="$2"; shift 2 ;;
		--out) OUT_CSV="$2"; shift 2 ;;
		--report) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_rollup_history generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "rollup: $ROLLUP_FILE"
	echo "score: $ROLLUP_SCORE_FILE"
	echo "out: $OUT_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$ROLLUP_FILE" ]; then
	echo "result: missing_rollup" >>"$OUT_TXT"
	echo "rollup missing" >>"$OUT_TXT"
	exit 0
fi

get_value() {
	local file="$1" key="$2"
	awk -v key="$key" '$1 == key ":" { print $2; exit }' "$file"
}

entries=$(get_value "$ROLLUP_FILE" "entries")
window=$(get_value "$ROLLUP_FILE" "window")
delta_alerts=$(get_value "$ROLLUP_FILE" "delta_alerts")
delta_score=$(get_value "$ROLLUP_FILE" "delta_score")
rollup_result=$(get_value "$ROLLUP_FILE" "result")
if [ -f "$ROLLUP_SCORE_FILE" ]; then
	score=$(get_value "$ROLLUP_SCORE_FILE" "score")
	score_result=$(get_value "$ROLLUP_SCORE_FILE" "result")
else
	score="0"
	score_result="missing_score"
	echo "score missing: $ROLLUP_SCORE_FILE" >>"$OUT_TXT"
fi

entries="${entries:-0}"
window="${window:-0}"
delta_alerts="${delta_alerts:-0}"
delta_score="${delta_score:-0}"
rollup_result="${rollup_result:-unknown}"
score="${score:-0}"
score_result="${score_result:-unknown}"

if [ ! -f "$OUT_CSV" ]; then
	echo "date,entries,window,delta_alerts,delta_score,rollup_result,score,score_result" >"$OUT_CSV"
fi

date_stamp="$(date '+%Y-%m-%d')"
echo "${date_stamp},${entries},${window},${delta_alerts},${delta_score},${rollup_result},${score},${score_result}" >>"$OUT_CSV"

{
	echo "date: $date_stamp"
	echo "entries: $entries"
	echo "window: $window"
	echo "delta_alerts: $delta_alerts"
	echo "delta_score: $delta_score"
	echo "rollup_result: $rollup_result"
	echo "score: $score"
	echo "score_result: $score_result"
	echo "result: ok"
} >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history rollup history generated: $OUT_TXT"
