#!/usr/bin/env bash
# Apply core manifests (namespace + MetalLB + sample ingress).
set -euo pipefail
PROFILE=${PROFILE:-ft-services}
KUBECTL=${KUBECTL:-kubectl}
LB_POOL=${LB_POOL:-192.168.49.240-192.168.49.250}

apply_file() {
  local file="$1"
  if [ -f "$file" ]; then
    $KUBECTL apply -f "$file"
  fi
}

echo "Applying namespace"
apply_file k8s/namespace.yaml

echo "Applying MetalLB namespace/controller placeholder"
apply_file k8s/metallb/metallb.yaml

echo "Applying MetalLB address pool with LB_POOL=$LB_POOL"
sed "s/\${LB_POOL:-192.168.49.240-192.168.49.250}/$LB_POOL/g" k8s/metallb/config.yaml | $KUBECTL apply -f -

if [ -f certs/secret.yaml ]; then
  echo "Applying ingress TLS secret"
  $KUBECTL apply -f certs/secret.yaml
fi

echo "Applying sample ingress whoami"
apply_file k8s/ingress/whoami.yaml

echo "Applying database layer (secrets + MariaDB)"
apply_file k8s/db/01-secrets.yaml
apply_file k8s/db/10-mariadb.yaml

echo "Applying WordPress + phpMyAdmin"
apply_file k8s/app/20-wordpress.yaml

echo "Applying FTPS service"
apply_file k8s/fts/30-ftps.yaml

echo "Applying monitoring stack (InfluxDB + Grafana)"
apply_file k8s/monitoring/00-monitor-secrets.yaml
apply_file k8s/monitoring/40-influxdb.yaml
apply_file k8s/monitoring/50-grafana.yaml
apply_file k8s/monitoring/60-grafana-dashboard.yaml
apply_file k8s/monitoring/70-influx-seed.yaml
