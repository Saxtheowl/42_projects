#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_summary_alerts_stats.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--out <file>]

Valide les champs cles du JSON build_summary_alerts_stats.
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
	echo "build_summary_alerts_stats_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$JSON_FILE" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for field in generated source alerts_total categories bundle_index_score result; do
	if ! grep -q "\"$field\"" "$JSON_FILE"; then
		echo "missing_field: $field" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if grep -q "\"categories\"" "$JSON_FILE"; then
	for field in gate checks preflight bundle alerts_items other; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: categories.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"bundle_index_score\"" "$JSON_FILE"; then
	for field in present score result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: bundle_index_score.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts stats validate generated: $OUT_TXT"
