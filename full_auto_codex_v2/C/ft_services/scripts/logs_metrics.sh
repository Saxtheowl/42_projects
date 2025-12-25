#!/bin/sh
LOG_DIR=${1:-${LOG_METRICS_DIR:-tests/env/logs}}
TOP_N=${2:-0}
PATTERN=${3:-}
ORDER="desc"
if [ "$TOP_N" -lt 0 ]; then
  ORDER="asc"
  TOP_N=$((TOP_N * -1))
fi
if [ ! -d "$LOG_DIR" ]; then
  echo "Log directory $LOG_DIR not found" >&2
  exit 1
fi
printf "Log metrics for directory %s\n" "$LOG_DIR"
printf "%-30s %12s %12s %15s\n" "Log file" "Status" "Connections" "Overloaded"
printf "%-30s %12s %12s %15s\n" "--------" "------" "-----------" "-----------"
total_status=0
total_connections=0
total_overloaded=0
if [ -n "$PATTERN" ]; then
  log_list=$(find "$LOG_DIR" -type f -name "*$PATTERN*.log" -print)
else
  log_list=$(find "$LOG_DIR" -type f -name '*.log' -print)
fi
if [ -z "$log_list" ]; then
  printf "No log files found in %s\n" "$LOG_DIR" >&2
  exit 1
fi
tmpfile=$(mktemp)
while read log; do
  status=$(grep -c "status check" "$log" 2>/dev/null || true)
  connections=$(grep -c "connections:" "$log" 2>/dev/null || true)
  overloaded=$(grep -c "overloaded" "$log" 2>/dev/null || true)
  total_status=$((total_status + status))
  total_connections=$((total_connections + connections))
  total_overloaded=$((total_overloaded + overloaded))
  printf "%-30s %12s %12s %15s\n" "$log" "$status" "$connections" "$overloaded"
  printf "%s|%s|%s|%s\n" "$overloaded" "$log" "$status" "$connections" >> "$tmpfile"
done <<EOF
$log_list
EOF
if [ "$TOP_N" -gt 0 ]; then
  printf "\nTop %s logs by overloaded count:\n" "$TOP_N"
  if [ "$ORDER" = "asc" ]; then
    sort -t '|' -k1,1n "$tmpfile"
  else
    sort -t '|' -k1,1nr "$tmpfile"
  fi | head -n "$TOP_N" | while IFS='|' read overloaded log status connections; do
    printf "%-30s %12s %12s %15s\n" "$log" "$status" "$connections" "$overloaded"
  done
fi
rm -f "$tmpfile"
printf "%-30s %12s %12s %15s\n" "Totals" "$total_status" "$total_connections" "$total_overloaded"
