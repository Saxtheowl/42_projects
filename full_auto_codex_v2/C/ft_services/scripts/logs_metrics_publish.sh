#!/bin/bash
# Prepare a tar.gz bundle of the latest metrics artifacts (csv/json/md/html/index/diff) for publishing.
set -euo pipefail

REPORTS_DIR=${REPORTS_DIR:-reports}
SUFFIX="status_top2"
OUTPUT="log_metrics_bundle.tar.gz"

while [ $# -gt 0 ]; do
  case "$1" in
    --reports=*) REPORTS_DIR=${1#*=}; shift ;;
    --reports) REPORTS_DIR=$2; shift 2 ;;
    --suffix=*) SUFFIX=${1#*=}; shift ;;
    --suffix) SUFFIX=$2; shift 2 ;;
    --output=*) OUTPUT=${1#*=}; shift ;;
    --output) OUTPUT=$2; shift 2 ;;
    --help)
      cat <<EOF
Usage: $0 [--reports DIR] [--suffix pattern_topN] [--output archive.tar.gz]
Bundles CSV/JSON/MD/HTML + index + diff (if present) into a tar.gz for sharing.
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

base="${REPORTS_DIR}/log_metrics_snapshot.${SUFFIX}"
files=(
  "${base}.csv"
  "${base}.json"
  "${base}.jsonl"
  "${base}.md"
  "${base}.html"
  "${REPORTS_DIR}/index.md"
  "${REPORTS_DIR}/index.html"
  "${REPORTS_DIR}/log_metrics_history.csv"
  "${REPORTS_DIR}/log_metrics_trend.md"
  "${REPORTS_DIR}/log_metrics_trend.html"
  "${base}.summary.md"
  "${base}.summary.html"
  "${REPORTS_DIR}/log_metrics_stats.md"
  "${REPORTS_DIR}/log_metrics_stats.html"
  "${REPORTS_DIR}/log_metrics_anomalies.md"
  "${REPORTS_DIR}/log_metrics_anomalies.html"
  "${REPORTS_DIR}/log_metrics_anomalies.json"
  "${REPORTS_DIR}/portal.html"
  "${REPORTS_DIR}/log_metrics_manifest.json"
  "${REPORTS_DIR}/log_metrics_checksums.txt"
  "${REPORTS_DIR}/log_metrics_overview.md"
  "${REPORTS_DIR}/log_metrics_overview.html"
  "${REPORTS_DIR}/log_metrics_latest.json"
  "${REPORTS_DIR}/log_metrics_latest.html"
  "${REPORTS_DIR}/log_metrics_latest.md"
)
[ -f "${REPORTS_DIR}/log_metrics_badge.svg" ] && files+=("${REPORTS_DIR}/log_metrics_badge.svg")
[ -f "${REPORTS_DIR}/log_metrics_badge_history.csv" ] && files+=("${REPORTS_DIR}/log_metrics_badge_history.csv")
[ -f "${REPORTS_DIR}/log_metrics_badge_history.md" ] && files+=("${REPORTS_DIR}/log_metrics_badge_history.md")
[ -f "${REPORTS_DIR}/log_metrics_badge_history.html" ] && files+=("${REPORTS_DIR}/log_metrics_badge_history.html")
[ -f "${REPORTS_DIR}/log_metrics_guard_summary.md" ] && files+=("${REPORTS_DIR}/log_metrics_guard_summary.md")
[ -f "${REPORTS_DIR}/log_metrics_guard_summary.html" ] && files+=("${REPORTS_DIR}/log_metrics_guard_summary.html")
[ -f "${REPORTS_DIR}/log_metrics_guard_summary.json" ] && files+=("${REPORTS_DIR}/log_metrics_guard_summary.json")
[ -f "${REPORTS_DIR}/log_metrics_guard_summary.csv" ] && files+=("${REPORTS_DIR}/log_metrics_guard_summary.csv")
[ -f "${REPORTS_DIR}/log_metrics_compare.md" ] && files+=("${REPORTS_DIR}/log_metrics_compare.md")
[ -f "${REPORTS_DIR}/log_metrics_compare.html" ] && files+=("${REPORTS_DIR}/log_metrics_compare.html")
[ -f "${REPORTS_DIR}/log_metrics_run_summary.md" ] && files+=("${REPORTS_DIR}/log_metrics_run_summary.md")
[ -f "${REPORTS_DIR}/log_metrics_run_summary.html" ] && files+=("${REPORTS_DIR}/log_metrics_run_summary.html")
[ -f "${REPORTS_DIR}/log_metrics_sitemap.md" ] && files+=("${REPORTS_DIR}/log_metrics_sitemap.md")
[ -f "${REPORTS_DIR}/log_metrics_sitemap.html" ] && files+=("${REPORTS_DIR}/log_metrics_sitemap.html")
[ -f "${REPORTS_DIR}/log_metrics_sitemap.json" ] && files+=("${REPORTS_DIR}/log_metrics_sitemap.json")
[ -f "${REPORTS_DIR}/log_metrics_status.json" ] && files+=("${REPORTS_DIR}/log_metrics_status.json")
[ -f "${REPORTS_DIR}/log_metrics_status_badge.svg" ] && files+=("${REPORTS_DIR}/log_metrics_status_badge.svg")
[ -f "${REPORTS_DIR}/log_metrics_overall_history.csv" ] && files+=("${REPORTS_DIR}/log_metrics_overall_history.csv")

missing=()
for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then
    missing+=("$f")
  fi
done
if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing artifacts: ${missing[*]}" >&2
  exit 1
fi

tar -czf "$OUTPUT" -C "$REPORTS_DIR" "${files[@]/${REPORTS_DIR}\//}"
echo "Bundle written to $OUTPUT"
