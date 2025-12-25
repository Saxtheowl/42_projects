#!/bin/bash
# Prune old metrics snapshots while keeping the latest N (per suffix).
set -euo pipefail

REPORTS_DIR=${REPORTS_DIR:-reports}
SUFFIX="status_top2"
KEEP=5
DRY_RUN=false

while [ $# -gt 0 ]; do
  case "$1" in
    --reports=*) REPORTS_DIR=${1#*=}; shift ;;
    --reports) REPORTS_DIR=$2; shift 2 ;;
    --suffix=*) SUFFIX=${1#*=}; shift ;;
    --suffix) SUFFIX=$2; shift 2 ;;
    --keep=*) KEEP=${1#*=}; shift ;;
    --keep) KEEP=$2; shift 2 ;;
    --dry-run) DRY_RUN=true; shift ;;
    --help)
      cat <<EOF
Usage: $0 [--reports DIR] [--suffix pattern_topN] [--keep N] [--dry-run]
Prunes old snapshots matching log_metrics_snapshot.<suffix>.* keeping the latest N files per extension.
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

if [ ! -d "$REPORTS_DIR" ]; then
  echo "Reports directory $REPORTS_DIR not found" >&2
  exit 1
fi

extensions=(csv json jsonl md html)
removed=false
for ext in "${extensions[@]}"; do
  pattern="${REPORTS_DIR}/log_metrics_snapshot.${SUFFIX}.${ext}"
  matches=($(ls -1t $pattern 2>/dev/null || true))
  if [ ${#matches[@]} -le $KEEP ]; then
    continue
  fi
  to_remove=("${matches[@]:$KEEP}")
  for file in "${to_remove[@]}"; do
    echo "[prune] removing $file"
    removed=true
    if [ "$DRY_RUN" = false ]; then
      rm -f "$file"
    fi
  done
done

if [ "$removed" = false ]; then
  echo "Nothing to prune (keep=$KEEP)."
fi
