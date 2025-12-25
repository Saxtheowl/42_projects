#!/usr/bin/env bash
# Quick status script: pods/services/ingresses in ft-services and MetalLB IPs.
set -euo pipefail
KUBECTL=${KUBECTL:-kubectl}
PROFILE=${PROFILE:-ft-services}

if command -v minikube >/dev/null 2>&1; then
  echo "[minikube] ip:" $(minikube -p "$PROFILE" ip 2>/dev/null || echo "N/A")
fi

echo "[namespace] pods"
$KUBECTL get pods -n ft-services -o wide || true

echo "[namespace] services"
$KUBECTL get svc -n ft-services || true

echo "[namespace] ingress"
$KUBECTL get ingress -n ft-services || true

echo "[metallb] addresspools"
$KUBECTL get ippools.metallb.io -A || true
