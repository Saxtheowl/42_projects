#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats_history_rollup_trend.json"
WINDOW=20

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--json <file>] [--window <n>]

Resume l'historique rollup stats alertes sur une fenetre.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) HISTORY_CSV="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		--window) WINDOW="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_rollup_trend generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $HISTORY_CSV"
	echo "window: $WINDOW"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

read -r count avg_delta_alerts avg_delta_score avg_score warn_rollup warn_score <<EOF
$(tail -n +2 "$HISTORY_CSV" | tail -n "$WINDOW" | awk -F',' '
	{
		count++
		delta_alerts += ($4 + 0)
		delta_score += ($5 + 0)
		score += ($7 + 0)
		if ($6 != "ok") warn_rollup++
		if ($8 != "ok") warn_score++
	}
	END {
		avg_delta_alerts = (count > 0) ? int(delta_alerts / count) : 0
		avg_delta_score = (count > 0) ? int(delta_score / count) : 0
		avg_score = (count > 0) ? int(score / count) : 0
		printf "%d %d %d %d %d %d", count, avg_delta_alerts, avg_delta_score, avg_score, warn_rollup, warn_score
	}
')
EOF

{
	echo "entries: $count"
	echo "avg_delta_alerts: $avg_delta_alerts"
	echo "avg_delta_score: $avg_delta_score"
	echo "avg_score: $avg_score"
	echo "warn_rollup: $warn_rollup"
	echo "warn_score: $warn_score"
} >>"$OUT_TXT"

result="ok"
if [ "$warn_rollup" -gt 0 ] || [ "$warn_score" -gt 0 ]; then
	result="warn"
fi

echo "result: $result" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"window\": $WINDOW,"
	echo "  \"entries\": $count,"
	echo "  \"avg_delta_alerts\": $avg_delta_alerts,"
	echo "  \"avg_delta_score\": $avg_delta_score,"
	echo "  \"avg_score\": $avg_score,"
	echo "  \"warn_rollup\": $warn_rollup,"
	echo "  \"warn_score\": $warn_score,"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats history rollup trend generated: $OUT_TXT"
