#!/bin/sh
CONFIG=${1:-tests/env/ft_services_status.conf}
MAX=${2:-15}
./scripts/show_config.sh "$CONFIG" || exit 1
./scripts/clean_log.sh "$CONFIG" || exit 1
./scripts/monitor_status.sh "$CONFIG" "$MAX" || exit 1
./scripts/log_summary.sh "$CONFIG" || exit 1
./scripts/stress_max_connections.sh "$CONFIG" "$MAX" || exit 0
