#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required." >&2
  exit 1
fi

vhost_enc=$(python3 - <<'PY'
import os,urllib.parse
v=os.environ.get("VHOST","/")
print(urllib.parse.quote(v, safe=""))
PY
)

purge_queue() {
  local queue="$1"
  curl -fsS -u "${USER}:${PASS}" -X DELETE "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${queue}/contents" >/dev/null
}

fetch_messages() {
  local queue="$1"
  local count="$2"
  curl -fsS -u "${USER}:${PASS}" \
    -H "Content-Type: application/json" \
    -X POST "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${queue}/get" \
    -d "{\"count\":${count},\"ackmode\":\"ack_requeue_false\",\"encoding\":\"auto\",\"truncate\":50000}"
}

echo "Checking topology..."
"${ROOT}/scripts/check_rabbitmq.sh" >/dev/null
"${ROOT}/scripts/validate_rabbitmq.sh" >/dev/null

purge_queue "grant_contracts"
purge_queue "grant_other_documents"

echo "Publishing routing key grant.1.contract..."
EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="grant.1.contract" "${ROOT}/scripts/publish_test_message.sh" >/dev/null

contracts=$(fetch_messages "grant_contracts" 1)
others=$(fetch_messages "grant_other_documents" 1)

CONTRACTS="${contracts}" OTHERS="${others}" python3 - <<'PY'
import json,sys,os
contracts=json.loads(os.environ["CONTRACTS"])
others=json.loads(os.environ["OTHERS"])
if len(contracts) != 1:
    print("Expected 1 message in grant_contracts, got", len(contracts), file=sys.stderr)
    sys.exit(1)
if len(others) != 1:
    print("Expected 1 message in grant_other_documents, got", len(others), file=sys.stderr)
    sys.exit(1)
print("Routing OK: grant.1.contract delivered to both queues.")
PY
