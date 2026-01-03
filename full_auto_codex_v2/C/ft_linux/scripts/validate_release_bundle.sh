#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUNDLE="${BUNDLE:-$ROOT/work/release_bundle.tar.gz}"
REPORT_DIR="$ROOT/reports"
OUT="$REPORT_DIR/release_bundle_report.txt"

usage() {
	cat <<EOF
Usage: $0 [--bundle <file>] [--out <file>]

Validates release bundle contents (reports/logs + optional images).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--bundle)
			BUNDLE="${2:-}"
			[ -n "$BUNDLE" ] || usage
			shift 2
			;;
		--out)
			OUT="${2:-}"
			[ -n "$OUT" ] || usage
			shift 2
			;;
		-h|--help)
			usage
			;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

if [ ! -f "$BUNDLE" ]; then
	echo "[ERR] Bundle introuvable: $BUNDLE" >&2
	exit 1
fi

missing=0
{
	echo "Release bundle report"
	echo "date: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "bundle: $BUNDLE"
	echo ""
	if tar -tzf "$BUNDLE" >/dev/null 2>&1; then
		tar -tzf "$BUNDLE" | grep -E '^reports/' >/dev/null 2>&1 || { echo "[MISS] reports/"; missing=$((missing + 1)); }
		tar -tzf "$BUNDLE" | grep -E '^logs/' >/dev/null 2>&1 || { echo "[MISS] logs/"; missing=$((missing + 1)); }
		tar -tzf "$BUNDLE" | grep -E '^work/boot_artifacts\.tar\.gz$' >/dev/null 2>&1 || { echo "[MISS] boot_artifacts.tar.gz"; missing=$((missing + 1)); }
		tar -tzf "$BUNDLE" | grep -E '^reports/summary\.md$' >/dev/null 2>&1 || { echo "[MISS] reports/summary.md"; missing=$((missing + 1)); }
	else
		echo "[ERR] Bundle illisible"
		missing=$((missing + 1))
	fi
	echo ""
	if [ "$missing" -eq 0 ]; then
		echo "result: OK"
	else
		echo "result: MISSING ($missing)"
	fi
} >"$OUT"

echo "[OK] Release bundle report: $OUT"
