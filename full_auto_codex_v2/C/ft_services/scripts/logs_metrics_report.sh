#!/bin/bash
# Generate a Markdown report from a metrics CSV snapshot (with Totals).
set -euo pipefail

INPUT=${1:-reports/log_metrics_snapshot.status_top2.csv}
OUTPUT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --input=*) INPUT=${1#*=}; shift ;;
    --input) INPUT=$2; shift 2 ;;
    --output=*) OUTPUT=${1#*=}; shift ;;
    --output) OUTPUT=$2; shift 2 ;;
    --help)
      cat <<EOF
Usage: $0 [--input PATH] [--output PATH]
Default input: reports/log_metrics_snapshot.status_top2.csv
Default output: <input>.md (same basename).
EOF
      exit 0
      ;;
    *) shift ;;
  esac
done

if [ ! -f "$INPUT" ]; then
  echo "Input CSV $INPUT not found" >&2
  exit 1
fi

if [ -z "$OUTPUT" ]; then
  OUTPUT="${INPUT%.csv}.md"
fi

timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

{
  echo "# Log Metrics Report"
  echo ""
  echo "- Source: \`$INPUT\`"
  echo "- Generated: $timestamp_utc"
  echo ""
  echo "| log_file | status_checks | connections | overloaded | overloaded_ratio | timestamp |"
  echo "| --- | --- | --- | --- | --- | --- |"
  tail -n +2 "$INPUT" | awk -F',' 'NF>=6 { printf("| %s | %s | %s | %s | %s | %s |\n",$2,$3,$4,$5,$6,$1) }'
} > "$OUTPUT"

echo "Report written to $OUTPUT"
