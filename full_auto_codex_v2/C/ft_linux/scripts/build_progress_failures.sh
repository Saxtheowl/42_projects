#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
PROGRESS_LOG="$REPORT_DIR/build_progress.csv"
OUT_TXT="$REPORT_DIR/build_progress_failures.txt"

usage() {
	cat <<EOF
Usage: $0 [--log <file>] [--out <file>]

Liste les echecs du build_progress et derniere erreur par paquet.
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
	echo "build_progress_failures generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "log: $PROGRESS_LOG"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$PROGRESS_LOG" ]; then
	echo "result: missing_log" >>"$OUT_TXT"
	echo "log missing" >>"$OUT_TXT"
	exit 0
fi

failures=$(awk -F',' 'NR>1 && $6=="fail" {print}' "$PROGRESS_LOG")
if [ -z "$failures" ]; then
	echo "result: ok" >>"$OUT_TXT"
	echo "no failures" >>"$OUT_TXT"
	exit 0
fi

echo "result: warn" >>"$OUT_TXT"
echo "" >>"$OUT_TXT"
echo "failures (latest per package):" >>"$OUT_TXT"
awk -F',' 'NR>1 && $6=="fail" {key=$2":"$3; last[key]=$0} END {for (k in last) print last[k]}' "$PROGRESS_LOG" \
	| sort >>"$OUT_TXT"

echo "[OK] Build progress failures generated: $OUT_TXT"
