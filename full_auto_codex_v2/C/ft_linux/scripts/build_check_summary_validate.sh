#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_check_summary.json"
OUT_TXT="$REPORT_DIR/build_check_summary_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--out <file>]

Valide les champs cles de build_check_summary.json.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--json) JSON_FILE="$2"; shift 2 ;;
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
	echo "build_check_summary_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$JSON_FILE" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for field in generated report stats trend gate result summary trend_last; do
	if ! grep -q "\"$field\"" "$JSON_FILE"; then
		echo "missing_field: $field" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if ! grep -q "\"coverage_rate\"" "$JSON_FILE"; then
	echo "missing_field: coverage_rate" >>"$OUT_TXT"
	missing=$((missing + 1))
fi
if ! grep -q "\"missing_rate\"" "$JSON_FILE"; then
	echo "missing_field: missing_rate" >>"$OUT_TXT"
	missing=$((missing + 1))
fi

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check summary validate generated: $OUT_TXT"
