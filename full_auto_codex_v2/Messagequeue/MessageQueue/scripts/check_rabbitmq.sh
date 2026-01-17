#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

if curl -fsS -u "${USER}:${PASS}" "http://${HOST}:${PORT}/api/overview" >/dev/null; then
  echo "RabbitMQ management API reachable at ${HOST}:${PORT}."
else
  echo "RabbitMQ management API not reachable at ${HOST}:${PORT}." >&2
  exit 1
fi
