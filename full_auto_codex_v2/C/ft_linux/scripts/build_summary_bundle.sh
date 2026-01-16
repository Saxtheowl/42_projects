#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPORT_DIR="$ROOT/reports"
OUT_TAR="$REPORT_DIR/build_summary_bundle.tar.gz"
OUT_SHA="$REPORT_DIR/build_summary_bundle.sha256"
OUT_TXT="$REPORT_DIR/build_summary_bundle.txt"

usage() {
	cat <<EOF
Usage: $0 [--out <tar.gz>] [--sha <file>] [--report <file>]

Genere une archive avec les rapports build_summary.
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

FILES=(
	"build_summary.json"
	"build_summary_validate.txt"
	"build_summary_report.txt"
	"build_summary_report_validate.txt"
	"build_summary_history.csv"
	"build_summary_trend.txt"
	"build_summary_trend.json"
	"build_summary_alerts.txt"
	"build_summary_alerts.json"
	"build_summary_alerts_validate.txt"
	"build_summary_alerts_history.csv"
	"build_summary_alerts_trend.txt"
	"build_summary_alerts_trend.json"
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
	"build_summary_alerts_stats_history_rollup_bundle.txt"
	"build_summary_alerts_stats_history_rollup_bundle_validate.txt"
	"build_summary_alerts_stats_history_rollup_overview.txt"
	"build_summary_alerts_stats_history_rollup_overview.json"
	"build_summary_alerts_stats_history_rollup_overview_validate.txt"
	"build_summary_alerts_stats_history_rollup_overview.md"
	"build_summary_alerts_stats_history_rollup_overview_md_validate.txt"
	"build_summary_alerts_stats_history_rollup_overview.html"
	"build_summary_alerts_stats_history_rollup_overview_html_validate.txt"
	"build_summary_alerts_stats_history_rollup_history.txt"
	"build_summary_alerts_stats_history_rollup_history.csv"
	"build_summary_alerts_stats_history_rollup_history_validate.txt"
	"build_summary_alerts_stats_history_rollup_history.md"
	"build_summary_alerts_stats_history_rollup_history_md_validate.txt"
	"build_summary_alerts_stats_history_rollup_history.html"
	"build_summary_alerts_stats_history_rollup_history_html_validate.txt"
	"build_summary_alerts_stats_history_rollup_trend.txt"
	"build_summary_alerts_stats_history_rollup_trend.json"
	"build_summary_alerts_stats_history_rollup_trend_validate.txt"
	"build_summary_alerts_stats_history_rollup_trend.md"
	"build_summary_alerts_stats_history_rollup_trend_md_validate.txt"
	"build_summary_alerts_stats_history_rollup_trend.html"
	"build_summary_alerts_stats_history_rollup_trend_html_validate.txt"
)

{
	echo "build_summary_bundle generated: $(date '+%Y-%m-%d %H:%M:%S')"
	echo "out: $OUT_TAR"
	echo "sha: $OUT_SHA"
	echo ""
} >"$OUT_TXT"

missing=0
present=()
for f in "${FILES[@]}"; do
	if [ -f "$REPORT_DIR/$f" ]; then
		present+=("$f")
	else
		echo "missing: $f" >>"$OUT_TXT"
		missing=$((missing + 1))
	fi
done

tar -czf "$OUT_TAR" -C "$REPORT_DIR" "${present[@]}"
if command -v sha256sum >/dev/null 2>&1; then
	sha256sum "$OUT_TAR" >"$OUT_SHA"
fi

{
	echo "files: ${#present[@]}"
	echo "missing_count: $missing"
	echo "result: ok"
} >>"$OUT_TXT"

echo "[OK] Build summary bundle generated: $OUT_TAR"
