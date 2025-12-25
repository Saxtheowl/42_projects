#!/bin/bash
set -euo pipefail
FORMAT=${1:-csv}
TOPN=2
PATTERN=status
./scripts/logs_metrics_export.sh --topn $TOPN --format $FORMAT > reports/log_metrics_snapshot.$FORMAT
if [[ "$FORMAT" == "csv" ]]; then
  tail -n 5 reports/log_metrics_snapshot.csv
else
  tail -n 1 reports/log_metrics_snapshot.json | jq
fi
