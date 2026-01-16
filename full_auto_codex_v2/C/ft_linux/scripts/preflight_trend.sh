#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/preflight_history.csv"
OUT_TXT="$REPORT_DIR/preflight_trend.txt"
OUT_JSON="$REPORT_DIR/preflight_trend.json"
WINDOW=20

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--json <file>] [--window <n>]

Resume l'historique preflight sur une fenetre.
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
	echo "preflight_trend generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $HISTORY_CSV"
	echo "window: $WINDOW"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

read -r read_count ok_count warn_count unknown_count avg_warns <<EOF
$(tail -n +"2" "$HISTORY_CSV" | tail -n "$WINDOW" | awk -F',' '
	{
		count++
		warns += ($2 + 0)
		if ($3 == "ok") ok++
		else if ($3 == "warn") warn++
		else unknown++
	}
	END {
		avg = (count > 0) ? int(warns / count) : 0
		printf "%d %d %d %d %d", count, ok, warn, unknown, avg
	}
')
EOF

{
	echo "entries: $read_count"
	echo "ok: $ok_count"
	echo "warn: $warn_count"
	echo "unknown: $unknown_count"
	echo "avg_warns: $avg_warns"
} >>"$OUT_TXT"

overall="ok"
if [ "$warn_count" -gt 0 ] || [ "$unknown_count" -gt 0 ]; then
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
	echo "  \"unknown\": $unknown_count,"
	echo "  \"avg_warns\": $avg_warns,"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Preflight trend generated: $OUT_TXT"
