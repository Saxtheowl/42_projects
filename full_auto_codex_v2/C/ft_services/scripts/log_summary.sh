#!/bin/sh
CONFIG=${1:-tests/env/ft_services.conf}
if [ ! -f "$CONFIG" ]; then
  echo "Config $CONFIG missing" >&2
  exit 1
fi
LOG=$(awk -F= '/^log_path/ {gsub(/^[\t ]+|[\t ]+$/,"", $2); print $2; exit}' "$CONFIG")
if [ -z "$LOG" ]; then
  echo "log_path missing in $CONFIG" >&2
  exit 1
fi
if [ ! -f "$LOG" ]; then
  echo "log file $LOG not found" >&2
  exit 1
fi
printf "Log summary for %s\n" "$LOG"
grep -c "status check" "$LOG" | awk '{print "status checks: "$1}'
grep -c "connections:" "$LOG" | awk '{print "count replies: "$1}'
grep -c "overloaded" "$LOG" | awk '{print "overload notices: "$1}'
