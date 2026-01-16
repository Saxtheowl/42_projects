#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_alerts_stats_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_table.txt"
OUT_CSV="$REPORT_DIR/build_summary_alerts_stats_history_table.csv"
LIMIT=10

usage() {
	cat <<USAGE
Usage: $0 [--history <csv>] [--csv <file>] [--out <file>] [--limit <n>]

Genere un extrait de l'historique stats alertes (table CSV).
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--history) HISTORY_CSV="$2"; shift 2 ;;
		--csv) OUT_CSV="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--limit) LIMIT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
	echo "[ERR] --limit doit etre un entier" >&2
	exit 1
fi

mkdir -p "$REPORT_DIR"

{
	echo "build_summary_alerts_stats_history_table generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "history: $HISTORY_CSV"
	echo "limit: $LIMIT"
	echo "csv: $OUT_CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_history" >>"$OUT_TXT"
	echo "history missing" >>"$OUT_TXT"
	exit 0
fi

header=$(head -n 1 "$HISTORY_CSV")
{
	echo "$header"
	tail -n +2 "$HISTORY_CSV" | tail -n "$LIMIT"
} >"$OUT_CSV"

entries=$(tail -n +2 "$OUT_CSV" | wc -l | tr -d ' ')

if [ "$entries" -lt 1 ]; then
	echo "entries: 0" >>"$OUT_TXT"
	echo "result: warn" >>"$OUT_TXT"
	{ echo "[WARN] No entries for history table: $OUT_TXT"; } >&2
	exit 0
fi

echo "entries: $entries" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history table generated: $OUT_TXT"
