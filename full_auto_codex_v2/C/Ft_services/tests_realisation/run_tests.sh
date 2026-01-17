#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

expect_file() {
    local path="$1"
    local label="$2"
    if [[ -f "$path" ]]; then
        echo "✅ $label"
    else
        echo "❌ $label"
        failures=$((failures + 1))
    fi
}

expect_grep() {
    local pattern="$1"
    local file="$2"
    local label="$3"
    if grep -Eq "$pattern" "$file"; then
        echo "✅ $label"
    else
        echo "❌ $label"
        failures=$((failures + 1))
    fi
}

expect_file "$ROOT/scripts/init_minikube.sh" "init_minikube.sh present"
expect_file "$ROOT/scripts/apply_all.sh" "apply_all.sh present"
expect_file "$ROOT/scripts/gen_certs.sh" "gen_certs.sh present"
expect_file "$ROOT/scripts/gen_hosts.sh" "gen_hosts.sh present"
expect_file "$ROOT/scripts/check_cluster.sh" "check_cluster.sh present"

expect_file "$ROOT/k8s/namespace.yaml" "namespace manifest present"
expect_file "$ROOT/k8s/metallb/config.yaml" "MetalLB config present"
expect_file "$ROOT/k8s/ingress/whoami.yaml" "whoami ingress manifest present"
expect_file "$ROOT/k8s/db/01-secrets.yaml" "database secrets manifest present"
expect_file "$ROOT/k8s/app/20-wordpress.yaml" "wordpress manifest present"
expect_file "$ROOT/k8s/fts/30-ftps.yaml" "ftps manifest present"
expect_file "$ROOT/k8s/monitoring/40-influxdb.yaml" "influxdb manifest present"
expect_file "$ROOT/k8s/monitoring/50-grafana.yaml" "grafana manifest present"

expect_grep "LB_POOL" "$ROOT/scripts/apply_all.sh" "apply_all.sh uses LB_POOL"
expect_grep "ingress-tls" "$ROOT/scripts/gen_certs.sh" "gen_certs.sh creates ingress secret"
expect_grep "metallb" "$ROOT/scripts/apply_all.sh" "apply_all.sh applies MetalLB"

echo
if [[ $failures -eq 0 ]]; then
    echo "All ft_services checks passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
