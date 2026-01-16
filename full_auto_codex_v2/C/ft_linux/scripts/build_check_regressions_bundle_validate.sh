#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
BUNDLE_TAR="$REPORT_DIR/build_check_regressions_bundle.tar.gz"
BUNDLE_SHA="$REPORT_DIR/build_check_regressions_bundle.sha256"
OUT_TXT="$REPORT_DIR/build_check_regressions_bundle_validate.txt"

REQUIRED=(
	"build_check_regressions.txt"
	"build_check_regressions_summary.txt"
	"build_check_regressions_summary.json"
	"build_check_regressions_top.txt"
	"build_check_regressions_top.json"
	"build_check_regressions_trend.txt"
	"build_check_regressions_trend.json"
	"build_check_regressions_groups.txt"
	"build_check_regressions_groups.json"
)

usage() {
	cat <<EOF
Usage: $0 [--tar <file>] [--sha <file>] [--out <file>]

Valide le bundle regressions (sha + contenu minimal).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--tar) BUNDLE_TAR="$2"; shift 2 ;;
		--sha) BUNDLE_SHA="$2"; shift 2 ;;
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
	echo "build_check_regressions_bundle_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "tar: $BUNDLE_TAR"
	echo "sha: $BUNDLE_SHA"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$BUNDLE_TAR" ]; then
	echo "result: missing_tar" >>"$OUT_TXT"
	echo "missing_tar: $BUNDLE_TAR" >>"$OUT_TXT"
	exit 0
fi
if [ ! -f "$BUNDLE_SHA" ]; then
	echo "result: missing_sha" >>"$OUT_TXT"
	echo "missing_sha: $BUNDLE_SHA" >>"$OUT_TXT"
	exit 0
fi

if ! (cd "$REPORT_DIR" && sha256sum -c "$(basename "$BUNDLE_SHA")" >/dev/null 2>&1); then
	echo "result: checksum_fail" >>"$OUT_TXT"
	echo "checksum: fail" >>"$OUT_TXT"
	exit 0
fi

missing=0
for file in "${REQUIRED[@]}"; do
	if ! tar -tzf "$BUNDLE_TAR" | grep -Fxq "$file"; then
		echo "missing_entry: $file" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -eq 0 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build check regressions bundle validate generated: $OUT_TXT"
