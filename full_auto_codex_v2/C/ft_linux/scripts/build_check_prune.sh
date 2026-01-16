#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
CSV_FILE="$REPORT_DIR/build_check_status.csv"
OUT_TXT="$REPORT_DIR/build_check_prune.txt"
DAYS=30
APPLY=0

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--days <n>] [--apply] [--out <file>]

Prune les entrees anciennes du CSV build_check_status (par date).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) CSV_FILE="$2"; shift 2 ;;
		--days) DAYS="$2"; shift 2 ;;
		--apply) APPLY=1; shift ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

cutoff=$(date -d "-$DAYS days" '+%Y-%m-%d')

{
	echo "build_check_prune generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $CSV_FILE"
	echo "days: $DAYS"
	echo "cutoff: $cutoff"
	echo "apply: $APPLY"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$CSV_FILE" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "missing_csv: $CSV_FILE" >>"$OUT_TXT"
	echo "[OK] Build check prune generated: $OUT_TXT"
	exit 0
fi

tmp_keep="$REPORT_DIR/.build_check_keep.$$"
tmp_drop="$REPORT_DIR/.build_check_drop.$$"

awk -F'|' -v cutoff="$cutoff" '
	NR==1 {print >keep; next}
	{
		day=substr($1,1,10);
		if (day < cutoff) {
			print >drop;
		} else {
			print >keep;
		}
	}
' keep="$tmp_keep" drop="$tmp_drop" "$CSV_FILE"

kept=$(wc -l <"$tmp_keep" | awk '{print $1}')
dropped=$(wc -l <"$tmp_drop" | awk '{print $1}')
before=$(wc -l <"$CSV_FILE" | awk '{print $1}')

echo "before: $before" >>"$OUT_TXT"
echo "kept: $kept" >>"$OUT_TXT"
echo "prune_candidates: $dropped" >>"$OUT_TXT"

if [ "$APPLY" -eq 1 ]; then
	mv "$tmp_keep" "$CSV_FILE"
	rm -f "$tmp_drop"
	echo "applied: yes" >>"$OUT_TXT"
	after=$(wc -l <"$CSV_FILE" | awk '{print $1}')
	echo "after: $after" >>"$OUT_TXT"
else
	rm -f "$tmp_keep" "$tmp_drop"
	echo "applied: no" >>"$OUT_TXT"
fi

if [ "$dropped" -gt 0 ]; then
	echo "result: warn" >>"$OUT_TXT"
else
	echo "result: ok" >>"$OUT_TXT"
fi

echo "[OK] Build check prune generated: $OUT_TXT"
