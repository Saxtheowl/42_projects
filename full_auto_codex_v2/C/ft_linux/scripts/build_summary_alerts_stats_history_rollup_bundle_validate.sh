#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
IN_TAR="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle.tar.gz"
IN_SHA="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle.sha256"
OUT_TXT="$REPORT_DIR/build_summary_alerts_stats_history_rollup_bundle_validate.txt"

usage() {
	cat <<EOF
Usage: $0 [--tar <file>] [--sha <file>] [--out <file>]

Valide l'archive rollup stats alertes (checksum + contenu).
EOF
	exit 1
}

while [ "$#" -gt 0 ]; do
	case "$1" in
		--tar) IN_TAR="$2"; shift 2 ;;
		--sha) IN_SHA="$2"; shift 2 ;;
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
	echo "build_summary_alerts_stats_history_rollup_bundle_validate generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "tar: $IN_TAR"
	echo "sha: $IN_SHA"
	echo ""
} >"$OUT_TXT"

if [ ! -f "$IN_TAR" ]; then
	echo "result: missing_bundle" >>"$OUT_TXT"
	echo "bundle missing" >>"$OUT_TXT"
	exit 0
fi

sha_ok=1
if [ -f "$IN_SHA" ] && command -v sha256sum >/dev/null 2>&1; then
	if ! sha256sum -c "$IN_SHA" >/dev/null 2>&1; then
		sha_ok=0
		echo "sha_mismatch: $IN_SHA" >>"$OUT_TXT"
	fi
else
	echo "sha_missing: $IN_SHA" >>"$OUT_TXT"
	sha_ok=0
fi

expected=(
	"build_summary_alerts_stats_history_rollup.txt"
	"build_summary_alerts_stats_history_rollup.json"
	"build_summary_alerts_stats_history_rollup_validate.txt"
	"build_summary_alerts_stats_history_rollup.md"
	"build_summary_alerts_stats_history_rollup_md_validate.txt"
	"build_summary_alerts_stats_history_rollup.html"
	"build_summary_alerts_stats_history_rollup_html_validate.txt"
	"build_summary_alerts_stats_history_rollup_score.txt"
	"build_summary_alerts_stats_history_rollup_score.json"
	"build_summary_alerts_stats_history_rollup_score_validate.txt"
	"build_summary_alerts_stats_history_rollup_score.md"
	"build_summary_alerts_stats_history_rollup_score_md_validate.txt"
	"build_summary_alerts_stats_history_rollup_score.html"
	"build_summary_alerts_stats_history_rollup_score_html_validate.txt"
)

missing=0
contents=$(tar -tzf "$IN_TAR")
for f in "${expected[@]}"; do
	if ! grep -q "^${f}$" <<<"$contents"; then
		echo "missing_file: $f" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

if [ "$missing" -eq 0 ] && [ "$sha_ok" -eq 1 ]; then
	echo "result: ok" >>"$OUT_TXT"
else
	echo "result: warn" >>"$OUT_TXT"
fi

echo "[OK] Build summary alerts stats history rollup bundle validate generated: $OUT_TXT"
