#!/usr/bin/env bash
set -euo pipefail

log_path=${FT_SERVICES_LOG:-/var/log/ft_services.log}
devices=("${FT_SERVICES_CONF:-/etc/ft_services.conf}" "${FT_SERVICES_DIR:-/etc/ft_services}" "${log_path}")
missing=0
for path in "${devices[@]}"; do
  if [[ -e "${path}" ]]; then
    echo "found ${path}"
  else
    echo "warning: ${path} missing"
    missing=1
  fi
done
if [[ ${missing} -eq 1 ]]; then
  echo "environment incomplete"
  exit 1
fi

echo "environment OK"
