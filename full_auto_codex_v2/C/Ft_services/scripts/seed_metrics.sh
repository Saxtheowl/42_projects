#!/usr/bin/env bash
# Injects synthetic metrics into InfluxDB (ft_services db).
set -euo pipefail
USER=${INFLUX_USER:-admin}
PASS=${INFLUX_PASSWORD:-admin}
HOST=${INFLUX_HOST:-influxdb.ft-services.svc.cluster.local}
PORT=${INFLUX_PORT:-8086}
DB=${INFLUX_DB:-ft_services}
BASE="http://${HOST}:${PORT}/write?db=${DB}"

post() {
  local line="$1"
  curl -s -u "${USER}:${PASS}" --data-binary "$line" "$BASE" >/dev/null
}

echo "Seeding synthetic metrics to ${HOST}:${PORT}/${DB}"
post "ingress_requests value=42"
post "mariadb_cpu_usage value=0.25"
post "mariadb_cpu_usage value=0.35"
post "mariadb_cpu_usage value=0.45"
echo "Done"
