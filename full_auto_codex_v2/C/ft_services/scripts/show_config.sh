#!/bin/sh
CONFIG=${1:-tests/env/ft_services.conf}
if [ ! -f "$CONFIG" ]; then
  echo "Config file $CONFIG not found" >&2
  exit 1
fi
print() { printf "%s\n" "$1"; }
print "[show_config] Using : $CONFIG"
print "$(grep -E '^(log_path|max_connections|port|backlog)' "$CONFIG" 2>/dev/null || true)"
