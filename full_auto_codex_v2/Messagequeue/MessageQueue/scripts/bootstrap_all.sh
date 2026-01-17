#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

docker compose -f "${ROOT}/docker-compose.yml" up -d
"${ROOT}/scripts/wait_rabbitmq.sh"
"${ROOT}/scripts/bootstrap_rabbitmq.sh"
"${ROOT}/scripts/validate_rabbitmq.sh"
"${ROOT}/scripts/test_routing.sh"
