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
ROUTING_KEYS="${ROUTING_KEYS:-}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/test_routing_matrix.sh [--help] [--silent] [--json]

Environment:
  GRANT_EXCHANGE        Exchange name (default: GRANT_EXCHANGE)
  CONTRACTS_QUEUE       Contracts queue (default: grant_contracts)
  OTHER_QUEUE           Other docs queue (default: grant_other_documents)
  CONTRACTS_ROUTING_KEY Pattern (default: grant.*.contract)
  OTHER_ROUTING_KEY     Pattern (default: grant.*)
  ROUTING_KEYS          CSV list of keys (default: sample set)
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
  if [[ "${silent}" -eq 1 ]]; then
    EXCHANGE="${GRANT_EXCHANGE}" ROUTING_KEY="${key}" \
      "${ROOT}/scripts/publish_test_message.sh" --silent >/dev/null
  else
    EXCHANGE="${GRANT_EXCHANGE}" ROUTING_KEY="${key}" \
      "${ROOT}/scripts/publish_test_message.sh" >/dev/null
  fi
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

keys=()
if [[ -n "${ROUTING_KEYS}" ]]; then
  IFS=',' read -r -a raw_keys <<< "${ROUTING_KEYS}"
  for key in "${raw_keys[@]}"; do
    trimmed="$(echo "${key}" | xargs)"
    if [[ -n "${trimmed}" ]]; then
      keys+=("${trimmed}")
    fi
  done
fi
if [ "${#keys[@]}" -eq 0 ]; then
  keys=(
    "grant.application"
    "grant.guarantee"
    "grant.1.contract"
    "grant.2.contract"
  )
fi

for key in "${keys[@]}"; do
  if [[ "${silent}" -eq 0 ]]; then
    echo "Publishing ${key}..."
  fi
  publish_key "${key}"
done

contracts=$(queue_count "${CONTRACTS_QUEUE}")
others=$(queue_count "${OTHER_QUEUE}")

EXPECTED=$(CONTRACTS_ROUTING_KEY="${CONTRACTS_ROUTING_KEY}" \
OTHER_ROUTING_KEY="${OTHER_ROUTING_KEY}" \
ROUTING_KEYS="$(printf '%s\n' "${keys[@]}")" \
python3 - <<'PY'
import os
raw=os.environ.get("ROUTING_KEYS","").strip()
keys=[k.strip() for k in raw.splitlines() if k.strip()]
contracts_pattern=os.environ.get("CONTRACTS_ROUTING_KEY","grant.*.contract")
others_pattern=os.environ.get("OTHER_ROUTING_KEY","grant.*")

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

contracts=sum(1 for k in keys if match_topic(contracts_pattern,k))
others=sum(1 for k in keys if match_topic(others_pattern,k))
print(f"{contracts} {others}")
PY
)

expected_contracts=$(echo "${EXPECTED}" | awk '{print $1}')
expected_others=$(echo "${EXPECTED}" | awk '{print $2}')

if [[ "${silent}" -eq 0 ]]; then
  echo "grant_contracts messages: ${contracts}"
  echo "grant_other_documents messages: ${others}"
fi

failed=0
if [ "${contracts}" -ne "${expected_contracts}" ]; then
  failed=1
fi
if [ "${others}" -ne "${expected_others}" ]; then
  failed=1
fi

if [[ "${json_output}" -eq 1 ]]; then
  ROUTING_KEYS_JSON="$(printf '%s\n' "${keys[@]}")" \
  EXPECTED_CONTRACTS="${expected_contracts}" EXPECTED_OTHERS="${expected_others}" \
  ACTUAL_CONTRACTS="${contracts}" ACTUAL_OTHERS="${others}" \
  FAILED="${failed}" python3 - <<'PY'
import json,os
keys=[k.strip() for k in os.environ.get("ROUTING_KEYS_JSON","").splitlines() if k.strip()]
expected_contracts=int(os.environ.get("EXPECTED_CONTRACTS","0"))
expected_others=int(os.environ.get("EXPECTED_OTHERS","0"))
actual_contracts=int(os.environ.get("ACTUAL_CONTRACTS","0"))
actual_others=int(os.environ.get("ACTUAL_OTHERS","0"))
failed=os.environ.get("FAILED","0") == "1"
status="error" if failed else "ok"
errors=[]
if actual_contracts != expected_contracts:
    errors.append(f"expected {expected_contracts} message(s) in grant_contracts, got {actual_contracts}")
if actual_others != expected_others:
    errors.append(f"expected {expected_others} message(s) in grant_other_documents, got {actual_others}")
print(json.dumps({
    "status": status,
    "keys": keys,
    "expected": {"grant_contracts": expected_contracts, "grant_other_documents": expected_others},
    "actual": {"grant_contracts": actual_contracts, "grant_other_documents": actual_others},
    "errors": errors,
}))
PY
  exit "${failed}"
fi

if [ "${contracts}" -ne "${expected_contracts}" ]; then
  echo "Expected ${expected_contracts} message in grant_contracts." >&2
  exit 1
fi
if [ "${others}" -ne "${expected_others}" ]; then
  echo "Expected ${expected_others} messages in grant_other_documents." >&2
  exit 1
fi

if [[ "${silent}" -eq 0 ]]; then
  echo "Routing matrix OK."
fi
