#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.json"
ROWS_CSV="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_rows.csv"
ALERTS_THRESHOLD=3
SCORE_DROP_THRESHOLD=5
LIMIT=10

usage() {
	cat <<USAGE
Usage: $0 [--history <csv>] [--out <file>] [--json <file>] [--rows <file>] [--alerts-threshold <n>] [--score-drop <n>] [--limit <n>]

Detecte des anomalies dans l'historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--history) HISTORY_CSV="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		--rows) ROWS_CSV="$2"; shift 2 ;;
		--alerts-threshold) ALERTS_THRESHOLD="$2"; shift 2 ;;
		--score-drop) SCORE_DROP_THRESHOLD="$2"; shift 2 ;;
		--limit) LIMIT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

if ! [[ "$ALERTS_THRESHOLD" =~ ^[0-9]+$ ]] || ! [[ "$SCORE_DROP_THRESHOLD" =~ ^[0-9]+$ ]] || ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
	echo "[ERR] thresholds/limit doivent etre des entiers" >&2
	exit 1
fi

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_anomalies generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "history: $HISTORY_CSV"
	echo "alerts_threshold: $ALERTS_THRESHOLD"
	echo "score_drop_threshold: $SCORE_DROP_THRESHOLD"
	echo "limit: $LIMIT"
	echo "rows: $ROWS_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_history" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$HISTORY_CSV\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

stats=$(awk -F',' -v a_thr="$ALERTS_THRESHOLD" -v s_thr="$SCORE_DROP_THRESHOLD" -v rows="$ROWS_CSV" '
	BEGIN { OFS=","; print "date,alerts_delta,score_delta,alerts_total,bundle_score" > rows }
	NR == 1 { next }
	NF >= 4 {
		count++
		date=$1
		alerts=$2 + 0
		score=$3 + 0
		last_date=date
		last_alerts=alerts
		last_score=score
		if (count == 1) { prev_alerts=alerts; prev_score=score; next }
		alerts_delta=alerts - prev_alerts
		score_delta=score - prev_score
		if (alerts_delta >= a_thr || score_delta <= -s_thr) {
			anomalies++
			print date, alerts_delta, score_delta, alerts, score >> rows
			if (anomalies == 1 || alerts_delta > max_alerts_delta) max_alerts_delta=alerts_delta
			if (anomalies == 1 || score_delta < min_score_delta) min_score_delta=score_delta
		}
		prev_alerts=alerts
		prev_score=score
	}
	END {
		if (count < 1) { print "0|0|0|0|unknown|0|0"; exit }
		if (anomalies == 0) { max_alerts_delta=0; min_score_delta=0 }
		printf "%d|%d|%d|%d|%s|%d|%d\n", count, anomalies+0, max_alerts_delta+0, min_score_delta+0, last_date, last_alerts+0, last_score+0
	}
' "$HISTORY_CSV")

IFS='|' read -r entries anomalies max_alerts_delta min_score_delta last_date last_alerts last_score <<<"$stats"
entries="${entries:-0}"
anomalies="${anomalies:-0}"
max_alerts_delta="${max_alerts_delta:-0}"
min_score_delta="${min_score_delta:-0}"
last_date="${last_date:-unknown}"
last_alerts="${last_alerts:-0}"
last_score="${last_score:-0}"

result="ok"
if [ "$entries" -lt 2 ]; then
	result="warn"
fi
if [ "$anomalies" -gt 0 ]; then
	result="warn"
fi

{
	echo "entries: $entries"
	echo "anomalies: $anomalies"
	echo "max_alerts_delta: $max_alerts_delta"
	echo "min_score_delta: $min_score_delta"
	echo "last_date: $last_date"
	echo "last_alerts_total: $last_alerts"
	echo "last_bundle_score: $last_score"
	echo "result: $result"
	if [ "$anomalies" -gt 0 ]; then
		echo ""
		echo "top_anomalies:"
		tail -n +2 "$ROWS_CSV" | head -n "$LIMIT" | while IFS=',' read -r d ad sd at bs; do
			echo "- $d alerts_delta=$ad score_delta=$sd alerts_total=$at bundle_score=$bs"
		done
	fi
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"thresholds\": {"
	echo "    \"alerts_delta\": $ALERTS_THRESHOLD,"
	echo "    \"score_drop\": $SCORE_DROP_THRESHOLD"
	echo "  },"
	echo "  \"entries\": $entries,"
	echo "  \"anomalies\": $anomalies,"
	echo "  \"max_alerts_delta\": $max_alerts_delta,"
	echo "  \"min_score_delta\": $min_score_delta,"
	echo "  \"last\": {"
	echo "    \"date\": \"$last_date\","
	echo "    \"alerts_total\": $last_alerts,"
	echo "    \"bundle_score\": $last_score"
	echo "  },"
	echo "  \"items\": ["
	first=1
	if [ -f "$ROWS_CSV" ]; then
		tail -n +2 "$ROWS_CSV" | head -n "$LIMIT" | while IFS=',' read -r d ad sd at bs; do
			[ -n "$d" ] || continue
			if [ "$first" -eq 0 ]; then
				echo ","
			fi
			first=0
			echo "    { \"date\": \"$d\", \"alerts_delta\": $ad, \"score_delta\": $sd, \"alerts_total\": $at, \"bundle_score\": $bs }"
		done
	fi
	if [ "$first" -eq 0 ]; then
		echo ""
	fi
	echo "  ],"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats history anomalies generated: $OUT_TXT"
