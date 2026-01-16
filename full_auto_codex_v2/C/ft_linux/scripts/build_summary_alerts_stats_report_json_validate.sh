#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
JSON_FILE="$REPORT_DIR/build_summary_alerts_stats_report.json"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_report_json_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--json <file>] [--out <file>]

Valide le JSON build_summary_alerts_stats_report.
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
	echo "build_summary_alerts_stats_report_json_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "json: $JSON_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$JSON_FILE" ]; then
	echo "result: missing_json" >>"$OUT_TXT"
	echo "json missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for field in generated source stats trend delta rollup rollup_score result; do
	if ! grep -q "\"$field\"" "$JSON_FILE"; then
		echo "missing_field: $field" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if grep -q "\"stats\"" "$JSON_FILE"; then
	for field in alerts_total bundle_score result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: stats.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"trend\"" "$JSON_FILE"; then
	for field in avg_alerts avg_bundle_score warn result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: trend.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"delta\"" "$JSON_FILE"; then
	for field in alerts_delta score_delta result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: delta.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"rollup\"" "$JSON_FILE"; then
	for field in entries window delta_alerts delta_score result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: rollup.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if grep -q "\"rollup_score\"" "$JSON_FILE"; then
	for field in score result; do
		if ! grep -q "\"$field\"" "$JSON_FILE"; then
			echo "missing_field: rollup_score.$field" >>"$OUT_TXT"
			missing=$((missing + 1))
		fi
	done
fi

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts stats report JSON validate generated: $OUT_TXT"
