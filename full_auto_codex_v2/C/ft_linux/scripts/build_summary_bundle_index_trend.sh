#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
HISTORY_CSV="$REPORT_DIR/build_summary_bundle_index_history.csv"
OUT_TXT="$REPORT_DIR/build_summary_bundle_index_trend.txt"
OUT_JSON="$REPORT_DIR/build_summary_bundle_index_trend.json"
WINDOW=20

usage() {
	cat <<EOF
Usage: $0 [--csv <file>] [--out <file>] [--json <file>] [--window <n>]

Resume l'historique du build_summary bundle index sur une fenetre.
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
	echo "build_summary_bundle_index_trend generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "csv: $HISTORY_CSV"
	echo "window: $WINDOW"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$HISTORY_CSV" ]; then
	echo "result: missing_csv" >>"$OUT_TXT"
	echo "csv missing" >>"$OUT_TXT"
	exit 0
fi

read -r read_count avg_files warn_count ok_count <<EOF
$(tail -n +"2" "$HISTORY_CSV" | tail -n "$WINDOW" | awk -F',' '
	{
		count++
		sum += ($2 + 0)
		if ($3 == "ok") ok++
		else warn++
	}
	END {
		avg = (count > 0) ? int(sum / count) : 0
		printf "%d %d %d %d", count, avg, warn, ok
	}
')
EOF

{
	echo "entries: $read_count"
	echo "avg_files: $avg_files"
	echo "warn: $warn_count"
	echo "ok: $ok_count"
} >>"$OUT_TXT"

overall="ok"
if [ "$warn_count" -gt 0 ]; then
	overall="warn"
fi
echo "result: $overall" >>"$OUT_TXT"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$HISTORY_CSV\","
	echo "  \"window\": $WINDOW,"
	echo "  \"entries\": $read_count,"
	echo "  \"avg_files\": $avg_files,"
	echo "  \"warn\": $warn_count,"
	echo "  \"ok\": $ok_count,"
	echo "  \"result\": \"$overall\""
	echo "}"
} >"$OUT_JSON"

echo "[OK] Build summary bundle index trend generated: $OUT_TXT"
