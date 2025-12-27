#!/bin/bash
# Generate and validate metrics snapshots for a given pattern/top_n.
set -euo pipefail

FORMAT="both"
PATTERN="status"
TOPN=2
LOG_DIR=${LOG_METRICS_DIR:-tests/env/logs}
REPORTS_DIR=${REPORTS_DIR:-reports}
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

usage() {
  cat <<EOF
Usage: $0 [--format csv|json|both] [--pattern PATTERN] [--topn N] [--dir LOG_DIR] [--reports DIR]
Default behaviour matches the documentation checklist: pattern=status, topn=2, outputs under reports/log_metrics_snapshot.status_top2.*.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --help) usage; exit 0 ;;
    --format=*) FORMAT=${1#*=}; shift ;;
    --format) FORMAT=$2; shift 2 ;;
    --pattern=*) PATTERN=${1#*=}; shift ;;
    --pattern) PATTERN=$2; shift 2 ;;
    --topn=*) TOPN=${1#*=}; shift ;;
    --topn) TOPN=$2; shift 2 ;;
    --dir=*) LOG_DIR=${1#*=}; shift ;;
    --dir) LOG_DIR=$2; shift 2 ;;
    --reports=*) REPORTS_DIR=${1#*=}; shift ;;
    --reports) REPORTS_DIR=$2; shift 2 ;;
    --) shift; break ;;
    -*)
      echo "Unknown option $1" >&2
      usage
      exit 1
      ;;
    *)
      # positional compatibility: single arg means format
      if [ -z "$FORMAT" ] || [ "$FORMAT" = "both" ]; then
        FORMAT=$1
        shift
      else
        shift
      fi
      ;;
  esac
done

if [[ "$LOG_DIR" != /* ]]; then
  LOG_DIR="$REPO_ROOT/$LOG_DIR"
fi
if [[ "$REPORTS_DIR" != /* ]]; then
  REPORTS_DIR="$REPO_ROOT/$REPORTS_DIR"
fi

if [ "$FORMAT" != "csv" ] && [ "$FORMAT" != "json" ] && [ "$FORMAT" != "both" ]; then
  echo "Unsupported format: $FORMAT" >&2
  exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
  echo "Log directory $LOG_DIR not found" >&2
  exit 1
fi

mkdir -p "$REPORTS_DIR"
pattern_label=$(printf "%s" "$PATTERN" | tr -cs '[:alnum:]_-' '_')
top_label=${TOPN#-}
suffix="top${top_label}"
[ -n "$pattern_label" ] && suffix="${pattern_label}_${suffix}"
base="${REPORTS_DIR}/log_metrics_snapshot.${suffix}"

run_export() {
  local fmt="$1"
  local out="${base}.${fmt}"
  echo "Exporting ${fmt} snapshot -> ${out}"
  "$SCRIPT_DIR/logs_metrics_export.sh" --dir "$LOG_DIR" --topn "$TOPN" --pattern "$PATTERN" --format "$fmt" > "$out"
  if [ "$fmt" = "csv" ]; then
    echo "[check] tail -n 5 ${out}"
    tail -n 5 "$out"
    if ! tail -n 1 "$out" | grep -q ",Totals,"; then
      echo "[error] Totals line missing in ${out}" >&2
      exit 1
    fi
  else
    echo "[check] jq '.[-1]' ${out}"
    if command -v jq >/dev/null 2>&1; then
      jq '.[-1]' "$out"
      totals=$(jq -r '.[-1].log_file' "$out")
      if [ "$totals" != "Totals" ]; then
        echo "[error] Totals object missing in ${out}" >&2
        exit 1
      fi
    else
      echo "jq not found, raw tail follows:" >&2
      tail -n 3 "$out"
    fi
  fi
}

case "$FORMAT" in
  csv) run_export "csv" ;;
  json) run_export "json" ;;
  both)
    run_export "csv"
    echo
    run_export "json"
    ;;
esac
