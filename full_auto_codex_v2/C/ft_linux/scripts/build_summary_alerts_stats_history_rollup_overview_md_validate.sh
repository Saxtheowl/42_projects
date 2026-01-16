#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
MD_FILE="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview.md"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_overview_md_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--md <file>] [--out <file>]

Valide le rapport Markdown synthese rollup.
EOF
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
	echo "build_summary_alerts_stats_history_rollup_overview_md_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "md: $MD_FILE"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$MD_FILE" ]; then
	echo "result: missing_md" >>"$OUT_TXT"
	echo "md missing" >>"$OUT_TXT"
	exit 0
fi

missing=0
for key in "# Build Summary Alerts Stats History Rollup Overview" "## Rollup" "## Score" "## Bundle" "Result:"; do
	if ! grep -q "$key" "$MD_FILE"; then
		echo "missing_line: $key" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts stats history rollup overview MD validate generated: $OUT_TXT"
