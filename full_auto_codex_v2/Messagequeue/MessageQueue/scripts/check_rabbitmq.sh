#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/check_rabbitmq.sh [--help] [--silent] [--json]

Environment:
  RABBITMQ_HOST  Hostname (default: localhost)
  RABBITMQ_PORT  API port (default: 15672)
  RABBITMQ_USER  Username (default: guest)
  RABBITMQ_PASS  Password (default: guest)
EOF
    exit 0
  elif [[ "${arg}" == "--silent" ]]; then
    silent=1
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if curl -fsS -u "${USER}:${PASS}" "http://${HOST}:${PORT}/api/overview" >/dev/null; then
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"ok\",\"host\":\"${HOST}\",\"port\":${PORT}}"
  elif [[ "${silent}" -eq 0 ]]; then
    echo "RabbitMQ management API reachable at ${HOST}:${PORT}."
  fi
else
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"error\",\"host\":\"${HOST}\",\"port\":${PORT}}"
  else
    echo "RabbitMQ management API not reachable at ${HOST}:${PORT}." >&2
  fi
  exit 1
fi
