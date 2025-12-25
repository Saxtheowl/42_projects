#!/bin/sh

CONFIGS=${@:-"tests/env/ft_services_status.conf tests/env/ft_services.conf"}
status_total=0
count_total=0
over_total=0

echo "Log summary for multiple configurations:"
for cfg in $CONFIGS; do
  if [ ! -f "$cfg" ]; then
    echo "Config $cfg missing" >&2
    exit 1
  fi
  log_path=$(awk -F= '/^log_path/ {gsub(/^[\t ]+|[\t ]+$/,"", $2); print $2; exit}' "$cfg")
  if [ -z "$log_path" ]; then
    echo "log_path missing in $cfg" >&2
    exit 1
  fi
  if [ ! -f "$log_path" ]; then
    echo "log file $log_path not found" >&2
    exit 1
  fi
  printf "\n=== Log summary for %s ===\n" "$cfg"
  status_count=$(grep -c "status check" "$log_path")
  count_replies=$(grep -c "connections:" "$log_path")
  overloaded=$(grep -c "overloaded" "$log_path")
  printf "status checks: %s\n" "$status_count"
  printf "count replies: %s\n" "$count_replies"
  printf "overload notices: %s\n" "$overloaded"
  status_total=$((status_total + status_count))
  count_total=$((count_total + count_replies))
  over_total=$((over_total + overloaded))
done
echo "\nTotals: status checks=$status_total connections=$count_total overloaded=$over_total"
