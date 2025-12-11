#!/bin/sh
CONFIG=${1:-tests/env/ft_services.conf}
LINES=${2:-20}
if [ ! -f "$CONFIG" ]; then
  echo "Missing config $CONFIG" >&2
  exit 1
fi
LOG_PATH=$(awk -F= '/^log_path/ {gsub(/^[ \t]+|[ \t]+$/,"", $2); print $2; exit}' "$CONFIG")
if [ -z "$LOG_PATH" ]; then
  echo "log_path not set in $CONFIG" >&2
  exit 1
fi
if [ ! -f "$LOG_PATH" ]; then
  echo "log not yet written: $LOG_PATH" >&2
  exit 1
fi
echo "== replaying last $LINES lines from $LOG_PATH =="
tail -n "$LINES" "$LOG_PATH" | grep --line-buffered "status check" || true
