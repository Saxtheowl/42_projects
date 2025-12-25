#!/bin/bash
# Generate sha256 checksums for key metrics artifacts.
# Usage: logs_metrics_checksums.sh --reports reports --suffix status_top2 --output reports/log_metrics_checksums.txt
set -euo pipefail

REPORTS_DIR=${REPORTS_DIR:-reports}
SUFFIX="status_top2"
OUTPUT=""

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
Usage: $0 [--reports DIR] [--suffix pattern_topN] [--output path]
Generate sha256 checksums for key metrics artifacts into a text file.
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

mkdir -p "$REPORTS_DIR"
[ -z "$OUTPUT" ] && OUTPUT="${REPORTS_DIR}/log_metrics_checksums.txt"

base="${REPORTS_DIR}/log_metrics_snapshot.${SUFFIX}"
files=(
  "${base}.csv"
  "${base}.json"
  "${base}.jsonl"
  "${base}.md"
  "${base}.html"
  "${base}.summary.md"
  "${base}.summary.html"
  "${REPORTS_DIR}/index.md"
  "${REPORTS_DIR}/index.html"
  "${REPORTS_DIR}/log_metrics_history.csv"
  "${REPORTS_DIR}/log_metrics_trend.md"
  "${REPORTS_DIR}/log_metrics_trend.html"
  "${REPORTS_DIR}/log_metrics_stats.md"
  "${REPORTS_DIR}/log_metrics_stats.html"
  "${REPORTS_DIR}/log_metrics_anomalies.md"
  "${REPORTS_DIR}/log_metrics_anomalies.html"
  "${REPORTS_DIR}/log_metrics_anomalies.json"
  "${REPORTS_DIR}/log_metrics_compare.md"
  "${REPORTS_DIR}/log_metrics_compare.html"
  "${REPORTS_DIR}/log_metrics_manifest.json"
  "${REPORTS_DIR}/portal.html"
  "${REPORTS_DIR}/log_metrics_bundle.tar.gz"
  "${REPORTS_DIR}/log_metrics_overview.md"
  "${REPORTS_DIR}/log_metrics_overview.html"
  "${REPORTS_DIR}/log_metrics_latest.json"
  "${REPORTS_DIR}/log_metrics_latest.html"
  "${REPORTS_DIR}/log_metrics_latest.md"
  "${REPORTS_DIR}/log_metrics_badge.svg"
  "${REPORTS_DIR}/log_metrics_badge_history.csv"
  "${REPORTS_DIR}/log_metrics_badge_history.md"
  "${REPORTS_DIR}/log_metrics_badge_history.html"
  "${REPORTS_DIR}/log_metrics_guard_summary.md"
  "${REPORTS_DIR}/log_metrics_guard_summary.html"
  "${REPORTS_DIR}/log_metrics_guard_summary.json"
  "${REPORTS_DIR}/log_metrics_guard_summary.csv"
)

missing=()
present=()
for f in "${files[@]}"; do
  if [ -f "$f" ]; then
    present+=("$f")
  else
    missing+=("$f")
  fi
done

if [ ${#present[@]} -eq 0 ]; then
  echo "No artifacts found for suffix ${SUFFIX} under ${REPORTS_DIR}" >&2
  exit 1
fi

(
  echo "# log_metrics checksums"
  cd "$REPORTS_DIR"
  for f in "${present[@]}"; do
    rel="${f#${REPORTS_DIR}/}"
    sha256sum "$rel"
  done
) > "$OUTPUT"

echo "Checksums written to $OUTPUT"
if [ ${#missing[@]} -gt 0 ]; then
  echo "Missing (not checksummed): ${missing[*]}"
fi
