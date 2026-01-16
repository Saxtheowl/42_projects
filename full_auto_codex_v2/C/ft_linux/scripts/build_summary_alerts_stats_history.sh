#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
STATS_TXT="$REPORT_DIR/build_summary_alerts_stats.txt"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history.txt"

usage() {
	cat <<EOF
Usage: $0 [--stats <file>] [--csv <file>] [--out <file>]

Ajoute une entree stats alertes au CSV historique.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--stats) STATS_TXT="$2"; shift 2 ;;
		--csv) HISTORY_CSV="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "stats: $STATS_TXT"
	echo "csv: $HISTORY_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$STATS_TXT" ]; then
	echo "result: missing_stats" >>"$OUT_TXT"
	echo "stats missing" >>"$OUT_TXT"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$STATS_TXT" | head -n 1 | awk '{print $2}'
}

entry_date=$(get_value "build_summary_alerts_stats")
alerts_total=$(get_value "alerts_total")
bundle_score=$(get_value "bundle_score")
result=$(get_value "result")

entry_date="${entry_date:-$(date '+%Y-%m-%d %H:%M:%S')}"
alerts_total="${alerts_total:-0}"
bundle_score="${bundle_score:-0}"
result="${result:-unknown}"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "generated,alerts_total,bundle_score,result" >"$HISTORY_CSV"
fi

echo "${entry_date},${alerts_total},${bundle_score},${result}" >>"$HISTORY_CSV"

{
	echo "last_generated: $entry_date"
	echo "alerts_total: $alerts_total"
	echo "bundle_score: $bundle_score"
	echo "result: $result"
	echo "result: ok"
} >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history generated: $OUT_TXT"
