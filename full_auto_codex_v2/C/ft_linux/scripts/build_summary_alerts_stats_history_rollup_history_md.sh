#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.csv"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.md"

usage() {
	cat <<USAGE
Usage: $0 [--csv <file>] [--out <file>]

Genere un tableau Markdown depuis l'historique rollup stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) HISTORY_CSV="$2"; shift 2 ;;
		--out) OUT_MD="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$HISTORY_CSV" ]; then
	{
		echo "# Build Summary Alerts Stats History Rollup History"
		echo ""
		echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
		echo ""
		echo "Result: missing"
	} >"$OUT_MD"
	exit 0
fi

{
	echo "# Build Summary Alerts Stats History Rollup History"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "| date | entries | window | delta_alerts | delta_score | rollup_result | score | score_result |"
	echo "| --- | --- | --- | --- | --- | --- | --- | --- |"
	tail -n +2 "$HISTORY_CSV" | while IFS=',' read -r date entries window delta_alerts delta_score rollup_result score score_result; do
		echo "| $date | $entries | $window | $delta_alerts | $delta_score | $rollup_result | $score | $score_result |"
	done
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history rollup history MD generated: $OUT_MD"
