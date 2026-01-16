#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TXT="$REPORT_DIR/preflight.txt"
OUT_JSON="$REPORT_DIR/preflight.json"
OUT_TXT="$REPORT_DIR/preflight_json.txt"

usage() {
	cat <<EOF
Usage: $0 [--in <file>] [--json <file>] [--out <file>]

Exporte un JSON a partir du rapport preflight.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--in) IN_TXT="$2"; shift 2 ;;
		--json) OUT_JSON="$2"; shift 2 ;;
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
	echo "preflight_json generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "in: $IN_TXT"
	echo "json: $OUT_JSON"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TXT" ]; then
	{
		echo "{"
		echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
		echo "  \"source\": \"$IN_TXT\","
		echo "  \"result\": \"missing\""
		echo "}"
	} >"$OUT_JSON"
	echo "result: missing_report" >>"$OUT_TXT"
	echo "missing_report: $IN_TXT" >>"$OUT_TXT"
	exit 0
fi

warn_count=$(grep -E '^warn_count:' "$IN_TXT" | head -n 1 | awk '{print $2}')
result=$(grep -E '^result:' "$IN_TXT" | head -n 1 | awk '{print $2}')
warn_count="${warn_count:-0}"
result="${result:-unknown}"

{
	echo "{"
	echo "  \"generated\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
	echo "  \"source\": \"$IN_TXT\","
	echo "  \"warn_count\": ${warn_count:-0},"
	echo "  \"result\": \"${result:-unknown}\""
	echo "}"
} >"$OUT_JSON"

echo "result: ok" >>"$OUT_TXT"
echo "[OK] Preflight JSON generated: $OUT_TXT"
