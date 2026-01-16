#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TAR="$REPORT_DIR/build_check_regressions_bundle.tar.gz"
OUT_SHA="$REPORT_DIR/build_check_regressions_bundle.sha256"
OUT_TXT="$REPORT_DIR/build_check_regressions_bundle.txt"

FILES=(
	"$REPORT_DIR/build_check_regressions.txt"
	"$REPORT_DIR/build_check_regressions_trend.txt"
	"$REPORT_DIR/build_check_regressions_trend.json"
	"$REPORT_DIR/build_check_regressions_groups.txt"
	"$REPORT_DIR/build_check_regressions_groups.json"
	"$REPORT_DIR/build_check_regressions_export.csv"
	"$REPORT_DIR/build_check_regressions_top.txt"
	"$REPORT_DIR/build_check_regressions_top.json"
	"$REPORT_DIR/build_check_regressions_summary.txt"
	"$REPORT_DIR/build_check_regressions_summary.json"
	"$REPORT_DIR/build_check_regressions_index.json"
	"$REPORT_DIR/build_check_regressions_report.md"
)

usage() {
	cat <<EOF
Usage: $0 [--out <tar>] [--sha <file>] [--report <file>]

Pack des rapports regressions checks avec checksum.
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--out) OUT_TAR="$2"; shift 2 ;;
		--sha) OUT_SHA="$2"; shift 2 ;;
		--report) OUT_TXT="$2"; shift 2 ;;
		-h|--help) usage ;;
		*)
			echo "[ERR] Option inconnue: $1" >&2
			usage
			;;
	esac
done

mkdir -p "$REPORT_DIR"

{
	echo "build_check_regressions_bundle generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "tar: $OUT_TAR"
	echo "sha: $OUT_SHA"
	echo ""
} >"$OUT_TXT"

missing=0
present=0
list=()
for file in "${FILES[@]}"; do
	if [ -f "$file" ]; then
		list+=("$file")
		echo "include: $file" >>"$OUT_TXT"
		present=$((present + 1))
	else
		echo "missing: $file" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$present" -eq 0 ]; then
	echo "result: missing_reports" >>"$OUT_TXT"
	echo "[OK] Build check regressions bundle generated: $OUT_TXT"
	exit 0
fi

tar -czf "$OUT_TAR" -C "$REPORT_DIR" $(printf '%s\n' "${list[@]}" | sed "s|$REPORT_DIR/||")
sha256sum "$OUT_TAR" >"$OUT_SHA"

echo "files: $present" >>"$OUT_TXT"
echo "missing_files: $missing" >>"$OUT_TXT"
echo "result: ok" >>"$OUT_TXT"

echo "[OK] Build check regressions bundle generated: $OUT_TXT"
