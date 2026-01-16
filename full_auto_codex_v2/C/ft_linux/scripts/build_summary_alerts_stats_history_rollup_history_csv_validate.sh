#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_history_csv_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Valide le CSV historique rollup stats alertes.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV_FILE="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_rollup_history_csv_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

header=$(head -n 1 "$CSV_FILE")
expected="date,entries,window,delta_alerts,delta_score,rollup_result,score,score_result"
if [ "$header" != "$expected" ]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "header_mismatch: $header" >>"$OUT_TXT"
	exit 0
fi

lines=$(tail -n +2 "$CSV_FILE" | wc -l | tr -d ' ')
if [ "$lines" -lt 1 ]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "no_entries" >>"$OUT_TXT"
	exit 0
fi

echo "entries: $lines" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history rollup history CSV validate generated: $OUT_TXT"
