#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
TIMEOUT="${TIMEOUT:-30}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

deadline=$((SECONDS + TIMEOUT))
while [ "$SECONDS" -lt "$deadline" ]; do
  if curl -fsS -u "${USER}:${PASS}" "http://${HOST}:${PORT}/api/overview" >/dev/null 2>&1; then
    echo "RabbitMQ ready at ${HOST}:${PORT}."
    exit 0
  fi
  sleep 1
done

echo "RabbitMQ not ready after ${TIMEOUT}s." >&2
exit 1
