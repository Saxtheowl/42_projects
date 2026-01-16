#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup.txt"
OUT_JSON="$REPORT_DIR/build_summary_alerts_stats_history_rollup.json"
WINDOW=7

usage() {
	cat <<USAGE
Usage: $0 [--history <csv>] [--out <file>] [--json <file>] [--window <n>]

Genere un rollup (fenetre glissante) sur l'historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--history) HISTORY_CSV="$2"; shift 2 ;;
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

if ! [[ "$WINDOW" =~ ^[0-9]+$ ]]; then
	echo "[ERR] --window doit etre un entier" >&2
	exit 1
fi

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_rollup generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "history: $HISTORY_CSV"
	echo "window: $WINDOW"
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

stats=$(awk -F',' -v w="$WINDOW" '
	NR == 1 { next }
	NF >= 4 {
		count++
		alerts[count]=$2 + 0
		score[count]=$3 + 0
	}
	END {
		if (count < 1) { print "0|0|0|0|0|0|0|0|0"; exit }
		last_window = w
		if (count < w) last_window = count
		last_start = count - last_window + 1
		for (i = last_start; i <= count; i++) { last_alerts += alerts[i]; last_score += score[i] }
		last_avg_alerts = last_alerts / last_window
		last_avg_score = last_score / last_window
		prev_present = 0
		prev_avg_alerts = 0
		prev_avg_score = 0
		if (count >= w * 2) {
			prev_present = 1
			prev_start = count - (w * 2) + 1
			prev_end = count - w
			for (i = prev_start; i <= prev_end; i++) { prev_alerts += alerts[i]; prev_score += score[i] }
			prev_avg_alerts = prev_alerts / w
			prev_avg_score = prev_score / w
		}
		delta_alerts = last_avg_alerts - prev_avg_alerts
		delta_score = last_avg_score - prev_avg_score
		printf "%d|%d|%d|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f\n", count, w, prev_present, last_avg_alerts, last_avg_score, prev_avg_alerts, prev_avg_score, delta_alerts, delta_score
	}
' "$HISTORY_CSV")

IFS='|' read -r entries window prev_present last_avg_alerts last_avg_score prev_avg_alerts prev_avg_score delta_alerts delta_score <<<"$stats"

entries="${entries:-0}"
window="${window:-$WINDOW}"
prev_present="${prev_present:-0}"
last_avg_alerts="${last_avg_alerts:-0}"
last_avg_score="${last_avg_score:-0}"
prev_avg_alerts="${prev_avg_alerts:-0}"
prev_avg_score="${prev_avg_score:-0}"
delta_alerts="${delta_alerts:-0}"
delta_score="${delta_score:-0}"

result="ok"
if [ "$entries" -lt "$WINDOW" ]; then
	result="warn"
fi
if [ "$prev_present" -eq 1 ]; then
	if awk -v da="$delta_alerts" -v ds="$delta_score" 'BEGIN { exit !(da > 0 || ds < 0) }'; then
		result="warn"
	fi
fi

{
	echo "entries: $entries"
	echo "window: $WINDOW"
	echo "prev_present: $prev_present"
	echo "last_avg_alerts: $last_avg_alerts"
	echo "last_avg_score: $last_avg_score"
	echo "prev_avg_alerts: $prev_avg_alerts"
	echo "prev_avg_score: $prev_avg_score"
	echo "delta_alerts: $delta_alerts"
	echo "delta_score: $delta_score"
	echo "result: $result"
} >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"window\": $WINDOW,"
	echo "  \"entries\": $entries,"
	echo "  \"prev_present\": $prev_present,"
	echo "  \"last\": {"
	echo "    \"avg_alerts\": $last_avg_alerts,"
	echo "    \"avg_score\": $last_avg_score"
	echo "  },"
	echo "  \"prev\": {"
	echo "    \"avg_alerts\": $prev_avg_alerts,"
	echo "    \"avg_score\": $prev_avg_score"
	echo "  },"
	echo "  \"delta\": {"
	echo "    \"alerts\": $delta_alerts,"
	echo "    \"score\": $delta_score"
	echo "  },"
	echo "  \"result\": \"$result\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary alerts stats history rollup generated: $OUT_TXT"
