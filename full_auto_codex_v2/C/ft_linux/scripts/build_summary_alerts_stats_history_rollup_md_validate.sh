#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
MD_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup.md"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_md_validate.txt"

usage() {
	cat <<USAGE
Usage: $0 [--md <file>] [--out <file>]

Valide le rapport Markdown rollup historique stats alertes.
USAGE
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--md) MD_FILE="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_rollup_md_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "md: $MD_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$MD_FILE" ]; then
	echo "result: missing_md" >>"$OUT_TXT"
	echo "md missing" >>"$OUT_TXT"
	exit 0
fi

if ! grep -q "# Build Summary Alerts Stats History Rollup" "$MD_FILE"; then
	echo "result: warn" >>"$OUT_TXT"
	echo "missing_title" >>"$OUT_TXT"
	exit 0
fi

if ! grep -q "| scope | avg_alerts | avg_score |" "$MD_FILE"; then
	echo "result: warn" >>"$OUT_TXT"
	echo "missing_table_header" >>"$OUT_TXT"
	exit 0
fi

echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build summary alerts stats history rollup MD validate generated: $OUT_TXT"
