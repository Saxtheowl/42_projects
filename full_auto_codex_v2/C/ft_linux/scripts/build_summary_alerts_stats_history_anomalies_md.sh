#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.txt"
OUT_MD="$REPORT_DIR/build_summary_alerts_stats_history_anomalies.md"
ROWS_CSV="$REPORT_DIR/build_summary_alerts_stats_history_anomalies_rows.csv"
LIMIT=10

usage() {
	cat <<USAGE
Usage: $0 [--report <file>] [--rows <file>] [--out <file>] [--limit <n>]

Genere un rapport Markdown pour les anomalies historiques.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
		--rows) ROWS_CSV="$2"; shift 2 ;;
		--out) OUT_MD="$2"; shift 2 ;;
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

if [ ! -f "$REPORT_FILE" ]; then
	{
		echo "# Build Summary Alerts Stats History Anomalies"
		echo ""
		echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
		echo ""
		echo "Result: missing"
	} >"$OUT_MD"
	exit 0
fi

get_value() {
	local key="$1"
	grep -E "^${key}:" "$REPORT_FILE" | head -n 1 | awk '{print $2}'
}

entries=$(get_value "entries")
anomalies=$(get_value "anomalies")
max_alerts_delta=$(get_value "max_alerts_delta")
min_score_delta=$(get_value "min_score_delta")
last_date=$(get_value "last_date")
last_alerts=$(get_value "last_alerts_total")
last_score=$(get_value "last_bundle_score")
result=$(get_value "result")

entries="${entries:-0}"
anomalies="${anomalies:-0}"
max_alerts_delta="${max_alerts_delta:-0}"
min_score_delta="${min_score_delta:-0}"
last_date="${last_date:-unknown}"
last_alerts="${last_alerts:-0}"
last_score="${last_score:-0}"
result="${result:-unknown}"

{
	echo "# Build Summary Alerts Stats History Anomalies"
	echo ""
	echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo ""
	echo "## Overview"
	echo "- entries: $entries"
	echo "- anomalies: $anomalies"
	echo "- max_alerts_delta: $max_alerts_delta"
	echo "- min_score_delta: $min_score_delta"
	echo "- result: $result"
	echo ""
	echo "## Last Entry"
	echo "- date: $last_date"
	echo "- alerts_total: $last_alerts"
	echo "- bundle_score: $last_score"
	echo ""
	echo "## Top anomalies"
	echo "| date | alerts_delta | score_delta | alerts_total | bundle_score |"
	echo "| --- | --- | --- | --- | --- |"
	if [ -f "$ROWS_CSV" ]; then
		tail -n +2 "$ROWS_CSV" | head -n "$LIMIT" | while IFS=',' read -r d ad sd at bs; do
			echo "| $d | $ad | $sd | $at | $bs |"
		done
	fi
} >"$OUT_MD"

echo "[OK] Build summary alerts stats history anomalies MD generated: $OUT_MD"
