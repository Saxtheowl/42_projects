#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
TABLE_CSV="$REPORT_DIR/build_summary_alerts_stats_history_table.csv"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_table.md"

usage() {
	cat <<USAGE
Usage: $0 [--csv <file>] [--out <file>]

Genere un tableau Markdown depuis la table historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) TABLE_CSV="$2"; shift 2 ;;
		--out) OUT_MD="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$TABLE_CSV" ]; then
	{
		echo "# Build Summary Alerts Stats History Table"
		echo ""
		echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
		echo ""
		echo "Result: missing"
	} >"$OUT_MD"
	exit 0
fi

{
	echo "# Build Summary Alerts Stats History Table"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "| date | alerts_total | bundle_score | result |"
	echo "| --- | --- | --- | --- |"
	tail -n +2 "$TABLE_CSV" | while IFS=',' read -r date alerts score result; do
		echo "| $date | $alerts | $score | $result |"
	done
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history table MD generated: $OUT_MD"
