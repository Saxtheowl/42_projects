#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_gate_history.csv"
OUT_TXT="$REPORT_DIR/build_gate_trend.txt"
OUT_JSON="$REPORT_DIR/build_gate_trend.json"
WINDOW=20

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--json <file>] [--window <n>]

Resume l'historique build_gate sur une fenetre.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--csv) HISTORY_CSV="$2"; shift 2 ;;
		--out) OUT_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
		--window) WINDOW="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_gate_trend generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $HISTORY_CSV"
	echo "window: $WINDOW"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

read -r read_count ok_count warn_count fail_count preflight_warn_count <<EOF
$(tail -n +"2" "$HISTORY_CSV" | tail -n "$WINDOW" | awk -F',' '
	{
		count++
		if ($2 != "ok") prewarn++
		if ($3 == "ok") ok++
		else if ($3 == "warn") warn++
		else if ($3 == "fail") fail++
	}
	END { printf "%d %d %d %d %d", count, ok, warn, fail, prewarn }
')
EOF

{
	echo "entries: $read_count"
	echo "ok: $ok_count"
	echo "warn: $warn_count"
	echo "fail: $fail_count"
	echo "preflight_warns: $preflight_warn_count"
} >>"$OUT_TXT"

overall="ok"
if [ "$fail_count" -gt 0 ] || [ "$warn_count" -gt 0 ]; then
	overall="warn"
fi
echo "result: $overall" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"window\": $WINDOW,"
	echo "  \"entries\": $read_count,"
	echo "  \"ok\": $ok_count,"
	echo "  \"warn\": $warn_count,"
	echo "  \"fail\": $fail_count,"
	echo "  \"preflight_warns\": $preflight_warn_count,"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build gate trend generated: $OUT_TXT"
