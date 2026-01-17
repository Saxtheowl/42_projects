#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

"${ROOT}/scripts/check_prereqs.sh"

if [ -f "${ROOT}/.env" ]; then
  "${ROOT}/scripts/load_env.sh" >/dev/null
fi

if "${ROOT}/scripts/check_rabbitmq.sh" >/dev/null 2>&1; then
  "${ROOT}/scripts/validate_rabbitmq.sh" >/dev/null
  echo "[ok] RabbitMQ topology validated"
else
  echo "[warn] RabbitMQ management API unreachable" >&2
fi

"${ROOT}/scripts/validate_payload.py"

echo "Doctor check completed."
