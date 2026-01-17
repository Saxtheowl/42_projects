#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

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

expect_env() {
    local var="$1"
    local file="$2"
    expect_grep "\\b${var}=" "$file" "Dockerfile defines ${var}"
}

template="${ROOT}/srcs/nginx.conf.template"
entrypoint="${ROOT}/srcs/entrypoint.sh"
dockerfile="${ROOT}/Dockerfile"

expect_grep "AUTO_INDEX" "$template" "nginx template exposes AUTO_INDEX"
expect_grep "envsubst" "$entrypoint" "entrypoint renders nginx template via envsubst"
expect_grep "/etc/nginx/templates/default.conf.template" "$entrypoint" "entrypoint reads nginx template"
expect_grep "/etc/nginx/sites-available/default" "$entrypoint" "entrypoint writes nginx config"
expect_grep "download_and_verify" "$entrypoint" "entrypoint verifies downloads"
expect_grep "wp core install" "$entrypoint" "entrypoint installs WordPress via WP-CLI"
expect_grep "blowfish_secret" "$entrypoint" "entrypoint sets phpMyAdmin blowfish secret"
expect_grep "MYSQL_ROOT_PASSWORD" "$entrypoint" "entrypoint uses MYSQL_ROOT_PASSWORD"
expect_grep "MYSQL_DATABASE" "$entrypoint" "entrypoint uses MYSQL_DATABASE"
expect_grep "MYSQL_USER" "$entrypoint" "entrypoint uses MYSQL_USER"

expect_env "WORDPRESS_VERSION" "$dockerfile"
expect_env "WORDPRESS_SHA256" "$dockerfile"
expect_env "PHPMYADMIN_VERSION" "$dockerfile"
expect_env "PHPMYADMIN_SHA256" "$dockerfile"

echo
if [[ $failures -eq 0 ]]; then
    echo "All ft_server checks passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
