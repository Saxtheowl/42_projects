#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="$ROOT/logs/system/build_times.csv"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_times.txt"

usage() {
	cat <<EOF
Usage: $0 [--log <file>] [--out <file>]

Genere un rapport des temps de build a partir de build_times.csv.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--log) LOG_FILE="$2"; shift 2 ;;
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
	echo "build_times report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "log: $LOG_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$LOG_FILE" ]; then
	echo "result: missing_log" >>"$OUT_TXT"
	echo "[WARN] build_times.csv introuvable." >>"$OUT_TXT"
	exit 0
fi

lines=$(wc -l <"$LOG_FILE" | tr -d ' ')
if [ "$lines" -le 1 ]; then
	echo "result: empty" >>"$OUT_TXT"
	echo "no entries" >>"$OUT_TXT"
	exit 0
fi

total=$(awk -F',' 'NR>1 {count++} END {print count+0}' "$LOG_FILE")
failures=$(awk -F',' 'NR>1 && $7=="fail" {count++} END {print count+0}' "$LOG_FILE")
total_duration=$(awk -F',' 'NR>1 {sum+=$6} END {print sum+0}' "$LOG_FILE")
avg_duration=0
if [ "$total" -gt 0 ]; then
	avg_duration=$((total_duration / total))
fi

echo "entries: $total" >>"$OUT_TXT"
echo "failures: $failures" >>"$OUT_TXT"
echo "total_duration_sec: $total_duration" >>"$OUT_TXT"
echo "avg_duration_sec: $avg_duration" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"

echo "slowest (duration_sec package version type status):" >>"$OUT_TXT"
awk -F',' 'NR>1 {printf "%s %s %s %s %s\n", $6, $1, $2, $3, $7}' "$LOG_FILE" \
	| sort -nr \
	| head -n 10 >>"$OUT_TXT"

if [ "$failures" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build times report generated: $OUT_TXT"
