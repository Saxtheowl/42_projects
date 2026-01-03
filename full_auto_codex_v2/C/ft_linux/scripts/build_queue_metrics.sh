#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV="$REPORT_DIR/build_queue.csv"
OUT_TXT="$REPORT_DIR/build_queue_metrics.txt"

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>]

Genere des statistiques a partir de build_queue.csv.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV="$2"; shift 2 ;;
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
	echo "build_queue_metrics generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

lines=$(wc -l <"$CSV" | tr -d ' ')
if [ "$lines" -le 1 ]; then
	echo "result: empty" >>"$OUT_TXT"
	echo "no entries" >>"$OUT_TXT"
	exit 0
fi

total=$(awk -F',' 'NR>1 {count++} END {print count+0}' "$CSV")
ok_count=$(awk -F',' 'NR>1 && $5=="ok" {count++} END {print count+0}' "$CSV")
skip_count=$(awk -F',' 'NR>1 && $5=="skip" {count++} END {print count+0}' "$CSV")
dry_count=$(awk -F',' 'NR>1 && $5=="dry-run" {count++} END {print count+0}' "$CSV")
fail_count=$(awk -F',' 'NR>1 && $5=="fail" {count++} END {print count+0}' "$CSV")
timeout_count=$(awk -F',' 'NR>1 && $5=="timeout" {count++} END {print count+0}' "$CSV")

total_duration=$(awk -F',' 'NR>1 && $4 ~ /^[0-9]+$/ {sum+=$4} END {print sum+0}' "$CSV")
avg_duration=0
if [ "$total" -gt 0 ]; then
	avg_duration=$((total_duration / total))
fi
ok_duration=$(awk -F',' 'NR>1 && $5=="ok" && $4 ~ /^[0-9]+$/ {sum+=$4} END {print sum+0}' "$CSV")
ok_avg=0
if [ "$ok_count" -gt 0 ]; then
	ok_avg=$((ok_duration / ok_count))
fi

echo "entries: $total" >>"$OUT_TXT"
echo "ok: $ok_count" >>"$OUT_TXT"
echo "skip: $skip_count" >>"$OUT_TXT"
echo "dry_run: $dry_count" >>"$OUT_TXT"
echo "fail: $fail_count" >>"$OUT_TXT"
echo "timeout: $timeout_count" >>"$OUT_TXT"
echo "total_duration_sec: $total_duration" >>"$OUT_TXT"
echo "avg_duration_sec: $avg_duration" >>"$OUT_TXT"
echo "ok_duration_sec: $ok_duration" >>"$OUT_TXT"
echo "ok_avg_duration_sec: $ok_avg" >>"$OUT_TXT"
if [ "$total" -gt 0 ]; then
	ok_rate=$((ok_count * 100 / total))
	echo "ok_rate_percent: $ok_rate" >>"$OUT_TXT"
fi

if [ "$total" -gt 0 ]; then
	echo "" >>"$OUT_TXT"
	echo "slowest (duration_sec command status):" >>"$OUT_TXT"
	awk -F',' 'NR>1 && $4 ~ /^[0-9]+$/ {printf "%s %s %s\n", $4, $1, $5}' "$CSV" \
		| sort -nr \
		| head -n 10 >>"$OUT_TXT"
	echo "" >>"$OUT_TXT"
	echo "longest_failures (duration_sec command status):" >>"$OUT_TXT"
	awk -F',' 'NR>1 && ($5=="fail" || $5=="timeout") && $4 ~ /^[0-9]+$/ {printf "%s %s %s\n", $4, $1, $5}' "$CSV" \
		| sort -nr \
		| head -n 10 >>"$OUT_TXT"
fi

if [ "$fail_count" -eq 0 ] && [ "$timeout_count" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build queue metrics generated: $OUT_TXT"
