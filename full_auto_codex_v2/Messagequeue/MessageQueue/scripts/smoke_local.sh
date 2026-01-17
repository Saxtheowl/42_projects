#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker is required." >&2
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "docker compose is required." >&2
  exit 1
fi

echo "Starting RabbitMQ (docker compose)..."
docker compose -f "${ROOT}/docker-compose.yml" up -d

"${ROOT}/scripts/wait_rabbitmq.sh"
"${ROOT}/scripts/check_rabbitmq.sh"
"${ROOT}/scripts/bootstrap_rabbitmq.sh"
"${ROOT}/scripts/validate_rabbitmq.sh"
"${ROOT}/scripts/test_routing.sh"

echo "Publishing test message..."
"${ROOT}/scripts/publish_test_message.sh" >/dev/null

echo "Queue counts:"
"${ROOT}/scripts/count_queue_messages.sh"

echo "Consume from grant_contracts..."
QUEUE="grant_contracts" "${ROOT}/scripts/consume_test_message.sh"

echo "Consume from grant_other_documents..."
QUEUE="grant_other_documents" "${ROOT}/scripts/consume_test_message.sh"

echo "Smoke test finished."
