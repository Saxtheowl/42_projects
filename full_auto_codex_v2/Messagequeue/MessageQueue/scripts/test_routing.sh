#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

GRANT_EXCHANGE="${GRANT_EXCHANGE:-GRANT_EXCHANGE}"
CONTRACTS_QUEUE="${CONTRACTS_QUEUE:-grant_contracts}"
OTHER_QUEUE="${OTHER_QUEUE:-grant_other_documents}"
CONTRACTS_ROUTING_KEY="${CONTRACTS_ROUTING_KEY:-grant.*.contract}"
OTHER_ROUTING_KEY="${OTHER_ROUTING_KEY:-grant.*}"
ROUTING_KEY="${ROUTING_KEY:-grant.1.contract}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/test_routing.sh [--help] [--silent] [--json]

Environment:
  GRANT_EXCHANGE        Exchange name (default: GRANT_EXCHANGE)
  CONTRACTS_QUEUE       Contracts queue (default: grant_contracts)
  OTHER_QUEUE           Other docs queue (default: grant_other_documents)
  CONTRACTS_ROUTING_KEY Pattern (default: grant.*.contract)
  OTHER_ROUTING_KEY     Pattern (default: grant.*)
  ROUTING_KEY           Routing key to test (default: grant.1.contract)
EOF
    exit 0
  elif [[ "${arg}" == "--silent" ]]; then
    silent=1
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
    silent=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

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

if [[ "${silent}" -eq 0 ]]; then
  echo "Checking topology..."
fi
if [[ "${json_output}" -eq 1 ]]; then
  "${ROOT}/scripts/check_rabbitmq.sh" --silent >/dev/null
  "${ROOT}/scripts/validate_rabbitmq.sh" --silent >/dev/null
else
  "${ROOT}/scripts/check_rabbitmq.sh" >/dev/null
  "${ROOT}/scripts/validate_rabbitmq.sh" >/dev/null
fi

purge_queue "${CONTRACTS_QUEUE}"
purge_queue "${OTHER_QUEUE}"

if [[ "${silent}" -eq 0 ]]; then
  echo "Publishing routing key ${ROUTING_KEY}..."
fi
if [[ "${silent}" -eq 1 ]]; then
  EXCHANGE="${GRANT_EXCHANGE}" ROUTING_KEY="${ROUTING_KEY}" \
    "${ROOT}/scripts/publish_test_message.sh" --silent >/dev/null
else
  EXCHANGE="${GRANT_EXCHANGE}" ROUTING_KEY="${ROUTING_KEY}" \
    "${ROOT}/scripts/publish_test_message.sh" >/dev/null
fi

contracts=$(fetch_messages "${CONTRACTS_QUEUE}" 1)
others=$(fetch_messages "${OTHER_QUEUE}" 1)

CONTRACTS="${contracts}" OTHERS="${others}" \
CONTRACTS_ROUTING_KEY="${CONTRACTS_ROUTING_KEY}" \
OTHER_ROUTING_KEY="${OTHER_ROUTING_KEY}" \
ROUTING_KEY="${ROUTING_KEY}" \
JSON_OUTPUT="${json_output}" \
SILENT="${silent}" \
python3 - <<'PY'
import json,sys,os
contracts=json.loads(os.environ["CONTRACTS"])
others=json.loads(os.environ["OTHERS"])
contracts_pattern=os.environ.get("CONTRACTS_ROUTING_KEY","grant.*.contract")
others_pattern=os.environ.get("OTHER_ROUTING_KEY","grant.*")
key=os.environ.get("ROUTING_KEY","grant.1.contract")
json_output = os.environ.get("JSON_OUTPUT") == "1"

def match_topic(pattern, routing):
    p=pattern.split(".")
    r=routing.split(".")
    i=j=0
    while i < len(p):
        if p[i] == "#":
            return True
        if j >= len(r):
            return False
        if p[i] != "*" and p[i] != r[j]:
            return False
        i += 1
        j += 1
    return j == len(r)

expected_contracts = 1 if match_topic(contracts_pattern, key) else 0
expected_others = 1 if match_topic(others_pattern, key) else 0
actual_contracts = len(contracts)
actual_others = len(others)
status = "ok"
errors = []
if actual_contracts != expected_contracts:
    status = "error"
    errors.append(f"expected {expected_contracts} message(s) in grant_contracts, got {actual_contracts}")
if actual_others != expected_others:
    status = "error"
    errors.append(f"expected {expected_others} message(s) in grant_other_documents, got {actual_others}")

if json_output:
    print(json.dumps({
        "status": status,
        "routing_key": key,
        "expected": {"grant_contracts": expected_contracts, "grant_other_documents": expected_others},
        "actual": {"grant_contracts": actual_contracts, "grant_other_documents": actual_others},
        "errors": errors,
    }))
    if status != "ok":
        sys.exit(1)
elif status != "ok":
    for err in errors:
        print(err, file=sys.stderr)
    sys.exit(1)
elif os.environ.get("SILENT") != "1":
    print(f"Routing OK for {key}.")
PY
