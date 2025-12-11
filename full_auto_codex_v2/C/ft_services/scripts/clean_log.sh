#!/bin/sh
# Cleans the log_path defined in a configuration file
CONFIG=${1:-tests/env/ft_services.conf}
if [ ! -f "$CONFIG" ]; then
  echo "Config file not found: $CONFIG" >&2
  exit 1
fi
LOG_PATH=$(awk -F= '/^log_path/ {gsub(/^[ \t]+|[ \t]+$/,"", $2); print $2; exit}' "$CONFIG")
if [ -z "$LOG_PATH" ]; then
  echo "log_path not defined in $CONFIG" >&2
  exit 1
fi
rm -f "$LOG_PATH" && mkdir -p "$(dirname "$LOG_PATH")"
