#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_report.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats_history_report.json"

usage() {
	cat <<USAGE
Usage: $0 [--history <csv>] [--out <file>] [--json <file>]

Genere un rapport a partir de l'historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--history) HISTORY_CSV="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "history: $HISTORY_CSV"
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

stats=$(awk -F',' '
	NR == 1 { next }
	NF >= 4 {
		count++
		alerts=$2 + 0
		score=$3 + 0
		result=$4
		last_date=$1
		last_alerts=alerts
		last_score=score
		last_result=result
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
		if (result == "ok") ok++
		else if (result == "warn") warn++
		else if (result == "unknown") unknown++
		else other++
	}
	END {
		if (count < 1) {
			print "0"
			exit
		}
		avg_alerts = sum_alerts / count
		avg_score = sum_score / count
		printf "%d|%s|%d|%d|%s|%d|%d|%.2f|%d|%d|%.2f|%d|%d|%d|%d\n", count, last_date, last_alerts, last_score, last_result, min_alerts, max_alerts, avg_alerts, min_score, max_score, avg_score, ok, warn, unknown, other
	}
' "$HISTORY_CSV")

if [ "$stats" = "0" ]; then
	echo "entries: 0" >>"$OUT_TXT"
	echo "note: no_entries" >>"$OUT_TXT"
	echo "result: warn" >>"$OUT_TXT"
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$HISTORY_CSV\","
		echo "  \"entries\": 0,"
		echo "  \"note\": \"no_entries\","
		echo "  \"result\": \"warn\""
		echo "}"
	} >"$OUT_JSON"
	exit 0
fi

IFS='|' read -r entries last_date last_alerts last_score last_result min_alerts max_alerts avg_alerts min_score max_score avg_score ok warn unknown other <<<"$stats"

entries="${entries:-0}"
last_alerts="${last_alerts:-0}"
last_score="${last_score:-0}"
min_alerts="${min_alerts:-0}"
max_alerts="${max_alerts:-0}"
min_score="${min_score:-0}"
max_score="${max_score:-0}"
avg_alerts="${avg_alerts:-0}"
avg_score="${avg_score:-0}"
ok="${ok:-0}"
warn="${warn:-0}"
unknown="${unknown:-0}"
other="${other:-0}"

result="ok"
if [ "$warn" -gt 0 ] || [ "$last_result" != "ok" ]; then
	result="warn"
fi

{
	echo "entries: $entries"
	echo "last_date: $last_date"
	echo "last_alerts_total: $last_alerts"
	echo "last_bundle_score: $last_score"
	echo "last_result: $last_result"
	echo "alerts_total_min: $min_alerts"
	echo "alerts_total_max: $max_alerts"
	echo "alerts_total_avg: $avg_alerts"
	echo "bundle_score_min: $min_score"
	echo "bundle_score_max: $max_score"
	echo "bundle_score_avg: $avg_score"
	echo "result_ok: $ok"
	echo "result_warn: $warn"
	echo "result_unknown: $unknown"
	echo "result_other: $other"
	echo "result: $result"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"entries\": $entries,"
	echo "  \"last\": {"
	echo "    \"date\": \"$last_date\","
	echo "    \"alerts_total\": $last_alerts,"
	echo "    \"bundle_score\": $last_score,"
	echo "    \"result\": \"$last_result\""
	echo "  },"
	echo "  \"alerts_total\": {"
	echo "    \"min\": $min_alerts,"
	echo "    \"max\": $max_alerts,"
	echo "    \"avg\": $avg_alerts"
	echo "  },"
	echo "  \"bundle_score\": {"
	echo "    \"min\": $min_score,"
	echo "    \"max\": $max_score,"
	echo "    \"avg\": $avg_score"
	echo "  },"
	echo "  \"results\": {"
	echo "    \"ok\": $ok,"
	echo "    \"warn\": $warn,"
	echo "    \"unknown\": $unknown,"
	echo "    \"other\": $other"
	echo "  },"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats history report generated: $OUT_TXT"
