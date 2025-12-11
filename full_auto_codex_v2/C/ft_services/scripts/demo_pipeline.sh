#!/bin/sh
configs=${@:-"tests/env/ft_services_status.conf"}
for cfg in $configs; do
  echo "=== Demo pipeline ($cfg) ==="
  scripts/show_config.sh "$cfg" || exit 1
  scripts/clean_log.sh "$cfg" || exit 1
  scripts/monitor_status.sh "$cfg" 10 || exit 1
  echo
done
