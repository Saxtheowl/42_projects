#!/usr/bin/env bash
# Generate /etc/hosts entries for ft_services domains using a LoadBalancer IP.
set -euo pipefail
LB_IP=${1:-}
if [ -z "$LB_IP" ]; then
  echo "Usage: $0 <loadbalancer_ip>" >&2
  exit 1
fi
DOMAINS=(whoami.local wordpress.local pma.local grafana.local)
for d in "${DOMAINS[@]}"; do
  echo "$LB_IP $d"
done
