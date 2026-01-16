#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
TABLE_CSV="$REPORT_DIR/build_summary_alerts_stats_history_table.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_table_validate.txt"

usage() {
	cat <<USAGE
Usage: $0 [--csv <file>] [--out <file>]

Valide le CSV de table historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) TABLE_CSV="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_table_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $TABLE_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$TABLE_CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

header=$(head -n 1 "$TABLE_CSV")
expected="generated,alerts_total,bundle_score,result"
if [ "$header" != "$expected" ]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "header_mismatch: $header" >>"$OUT_TXT"
	exit 0
fi

lines=$(tail -n +2 "$TABLE_CSV" | wc -l | tr -d ' ')
if [ "$lines" -lt 1 ]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "no_entries" >>"$OUT_TXT"
	exit 0
fi

echo "entries: $lines" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history table validate generated: $OUT_TXT"
