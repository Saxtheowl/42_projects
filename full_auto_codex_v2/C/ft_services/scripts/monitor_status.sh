#!/bin/sh
CONFIG=${1:-tests/env/ft_services.conf}
MAX=${2:-${MAX_CONNECTIONS:-10}}

print() { printf "%s\n" "$1"; }
if [ ! -f "$CONFIG" ]; then
  print "Config not found: $CONFIG" >&2
  exit 1
fi
print "[monitor_status] using config $CONFIG"
print "[monitor_status] cleaning log"
./scripts/clean_log.sh "$CONFIG" || exit 1
print "[monitor_status] waiting for STATUS"
./scripts/wait_for_status.sh "$CONFIG" || exit 1
print "[monitor_status] querying COUNT"
./scripts/query_count.sh "$CONFIG"
print "[monitor_status] exercising max connections ("$MAX" iterations)"
./scripts/test_max_connections.sh "$CONFIG" "$MAX"
print "[monitor_status] done"
