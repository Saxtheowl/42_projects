#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
REPORT_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.txt"
JSON_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--report <file>] [--json <file>] [--out <file>]

Valide la synthese rollup historique stats alertes.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--report) REPORT_FILE="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_rollup_overview_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "report: $REPORT_FILE"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$REPORT_FILE" ]; then
	echo "result: missing_report" >>"$OUT_TXT"
	echo "report missing" >>"$OUT_TXT"
	exit 0
fi

if ! grep -qE '^result:' "$REPORT_FILE"; then
	echo "result: warn" >>"$OUT_TXT"
	echo "missing_result_line" >>"$OUT_TXT"
	exit 0
fi

if [ ! -f "$JSON_FILE" ]; then
	echo "result: warn" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for field in rollup score bundle_validate result; do
	if ! grep -q "\"$field\"" "$JSON_FILE"; then
		echo "missing_field: $field" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if grep -q "\"rollup\"" "$JSON_FILE"; then
	for field in entries window delta_alerts delta_score result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: rollup.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"score\"" "$JSON_FILE"; then
	for field in value result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: score.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts stats history rollup overview validate generated: $OUT_TXT"
