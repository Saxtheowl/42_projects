#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TXT="$REPORT_DIR/build_orchestrator_report.txt"
SRC="$REPORT_DIR/build_orchestrator.txt"

usage() {
	cat <<EOF
Usage: $0 [--src <file>] [--out <file>]

Genere un rapport synthese a partir de build_orchestrator.txt.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--src) SRC="$2"; shift 2 ;;
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
	echo "build_orchestrator_report generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "src: $SRC"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$SRC" ]; then
	echo "result: missing_src" >>"$OUT_TXT"
	echo "source missing" >>"$OUT_TXT"
	exit 0
fi

tail -n 20 "$SRC" >>"$OUT_TXT"

if grep -q '^result: ok' "$SRC"; then
	echo "result: ok" >>"$OUT_TXT"
elif grep -q '^result: fail' "$SRC"; then
	echo "result: fail" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build orchestrator report generated: $OUT_TXT"
