#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
PROGRESS_LOG="$REPORT_DIR/build_progress.csv"
OUT_TXT="$REPORT_DIR/build_progress.txt"

usage() {
	cat <<EOF
Usage: $0 [--log <file>] [--out <file>]

Synthese du build_progress.csv (compteurs + dernieres entrees).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--log) PROGRESS_LOG="$2"; shift 2 ;;
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
	echo "build_progress report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "log: $PROGRESS_LOG"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$PROGRESS_LOG" ]; then
	echo "result: missing_log" >>"$OUT_TXT"
	echo "log missing" >>"$OUT_TXT"
	exit 0
fi

lines=$(wc -l <"$PROGRESS_LOG" | tr -d ' ')
if [ "$lines" -le 1 ]; then
	echo "result: empty" >>"$OUT_TXT"
	echo "no entries" >>"$OUT_TXT"
	exit 0
fi

total=$(awk -F',' 'NR>1 {count++} END {print count+0}' "$PROGRESS_LOG")
ok=$(awk -F',' 'NR>1 && $6=="ok" {count++} END {print count+0}' "$PROGRESS_LOG")
fail=$(awk -F',' 'NR>1 && $6=="fail" {count++} END {print count+0}' "$PROGRESS_LOG")
skip=$(awk -F',' 'NR>1 && $6=="skip" {count++} END {print count+0}' "$PROGRESS_LOG")
dry=$(awk -F',' 'NR>1 && $6=="dry-run" {count++} END {print count+0}' "$PROGRESS_LOG")

echo "entries: $total" >>"$OUT_TXT"
echo "ok: $ok" >>"$OUT_TXT"
echo "fail: $fail" >>"$OUT_TXT"
echo "skip: $skip" >>"$OUT_TXT"
echo "dry_run: $dry" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"
echo "last_entries:" >>"$OUT_TXT"
tail -n 10 "$PROGRESS_LOG" >>"$OUT_TXT"

if [ "$fail" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build progress report generated: $OUT_TXT"
