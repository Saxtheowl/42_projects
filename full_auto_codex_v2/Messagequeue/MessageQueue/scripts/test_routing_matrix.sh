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

queue_count() {
  local queue="$1"
  curl -fsS -u "${USER}:${PASS}" "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${queue}" \
    | python3 - <<'PY'
import json,sys
print(json.load(sys.stdin).get("messages", 0))
PY
}

publish_key() {
  local key="$1"
  EXCHANGE="GRANT_EXCHANGE" ROUTING_KEY="${key}" "${ROOT}/scripts/publish_test_message.sh" >/dev/null
}

echo "Checking topology..."
"${ROOT}/scripts/check_rabbitmq.sh" >/dev/null
"${ROOT}/scripts/validate_rabbitmq.sh" >/dev/null

purge_queue "grant_contracts"
purge_queue "grant_other_documents"

keys=(
  "grant.application"
  "grant.guarantee"
  "grant.1.contract"
  "grant.2.contract"
)

for key in "${keys[@]}"; do
  echo "Publishing ${key}..."
  publish_key "${key}"
done

contracts=$(queue_count "grant_contracts")
others=$(queue_count "grant_other_documents")

expected_contracts=1
expected_others=4

echo "grant_contracts messages: ${contracts}"
echo "grant_other_documents messages: ${others}"

if [ "${contracts}" -ne "${expected_contracts}" ]; then
  echo "Expected ${expected_contracts} message in grant_contracts." >&2
  exit 1
fi
if [ "${others}" -ne "${expected_others}" ]; then
  echo "Expected ${expected_others} messages in grant_other_documents." >&2
  exit 1
fi

echo "Routing matrix OK."
