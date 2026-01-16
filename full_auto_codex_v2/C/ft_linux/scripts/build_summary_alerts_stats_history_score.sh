#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_score.txt"

usage() {
	cat <<USAGE
Usage: $0 [--history <csv>] [--out <file>]

Calcule un score de stabilite pour l'historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--history) HISTORY_CSV="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_score generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "history: $HISTORY_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_history" >>"$OUT_TXT"
	echo "score: 0" >>"$OUT_TXT"
	exit 0
fi

stats=$(awk -F',' '
	NR == 1 { next }
	NF >= 4 {
		count++
		alerts=$2 + 0
		score=$3 + 0
		sum_alerts += alerts
		sum_score += score
		if (count == 1) {
			min_alerts=alerts
			max_alerts=alerts
			min_score=score
			max_score=score
		}
		if (alerts < min_alerts) min_alerts=alerts
		if (alerts > max_alerts) max_alerts=alerts
		if (score < min_score) min_score=score
		if (score > max_score) max_score=score
	}
	END {
		if (count < 1) { print "0"; exit }
		avg_alerts = sum_alerts / count
		avg_score = sum_score / count
		printf "%d|%d|%d|%.2f|%d|%d|%.2f\n", count, min_alerts, max_alerts, avg_alerts, min_score, max_score, avg_score
	}
' "$HISTORY_CSV")

if [ "$stats" = "0" ]; then
	echo "entries: 0" >>"$OUT_TXT"
	echo "result: warn" >>"$OUT_TXT"
	echo "score: 0" >>"$OUT_TXT"
	exit 0
fi

IFS='|' read -r entries min_alerts max_alerts avg_alerts min_score max_score avg_score <<<"$stats"

entries="${entries:-0}"
min_alerts="${min_alerts:-0}"
max_alerts="${max_alerts:-0}"
avg_alerts="${avg_alerts:-0}"
min_score="${min_score:-0}"
max_score="${max_score:-0}"
avg_score="${avg_score:-0}"

alert_range=$((max_alerts - min_alerts))
score_range=$((max_score - min_score))

# Penalites en fonction de l'amplitude des variations.
penalty_alerts=$((alert_range * 5))
penalty_score=$((score_range * 2))

score=$((100 - penalty_alerts - penalty_score))
if [ "$score" -lt 0 ]; then
	score=0
fi

result="ok"
if [ "$score" -lt 80 ]; then
	result="warn"
fi

{
	echo "entries: $entries"
	echo "alerts_total_min: $min_alerts"
	echo "alerts_total_max: $max_alerts"
	echo "alerts_total_avg: $avg_alerts"
	echo "bundle_score_min: $min_score"
	echo "bundle_score_max: $max_score"
	echo "bundle_score_avg: $avg_score"
	echo "alert_range: $alert_range"
	echo "score_range: $score_range"
	echo "score: $score"
	echo "result: $result"
} >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history score generated: $OUT_TXT"
