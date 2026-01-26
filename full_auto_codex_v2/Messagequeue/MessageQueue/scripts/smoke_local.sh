#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi

GRANT_EXCHANGE="${GRANT_EXCHANGE:-GRANT_EXCHANGE}"
CONTRACTS_QUEUE="${CONTRACTS_QUEUE:-grant_contracts}"
OTHER_QUEUE="${OTHER_QUEUE:-grant_other_documents}"
ROUTING_KEY="${ROUTING_KEY:-}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/smoke_local.sh [--help] [--silent] [--json]

Environment:
  GRANT_EXCHANGE  Exchange name (default: GRANT_EXCHANGE)
  CONTRACTS_QUEUE Contracts queue (default: grant_contracts)
  OTHER_QUEUE     Other docs queue (default: grant_other_documents)
  ROUTING_KEY     Routing key for test_routing (default: grant.1.contract)
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

if ! command -v docker >/dev/null 2>&1; then
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' '{"status":"error","step":"docker","error":"docker is required"}'
  else
    echo "docker is required." >&2
  fi
  exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' '{"status":"error","step":"docker_compose","error":"docker compose is required"}'
  else
    echo "docker compose is required." >&2
  fi
  exit 1
fi

if [[ "${silent}" -eq 0 ]]; then
  echo "Starting RabbitMQ (docker compose)..."
fi
docker compose -f "${ROOT}/docker-compose.yml" up -d

wait_status="ok"
check_status="ok"
bootstrap_status="ok"
validate_status="ok"
routing_status="ok"
publish_status="ok"
failed=0

if "${ROOT}/scripts/wait_rabbitmq.sh" --silent >/dev/null 2>&1; then
  wait_status="ok"
else
  wait_status="error"
  failed=1
fi
if "${ROOT}/scripts/check_rabbitmq.sh" --silent >/dev/null 2>&1; then
  check_status="ok"
else
  check_status="error"
  failed=1
fi
if "${ROOT}/scripts/bootstrap_rabbitmq.sh" --silent >/dev/null 2>&1; then
  bootstrap_status="ok"
else
  bootstrap_status="error"
  failed=1
fi
if "${ROOT}/scripts/validate_rabbitmq.sh" --silent >/dev/null 2>&1; then
  validate_status="ok"
else
  validate_status="error"
  failed=1
fi
if ROUTING_KEY="${ROUTING_KEY:-grant.1.contract}" "${ROOT}/scripts/test_routing.sh" --silent >/dev/null 2>&1; then
  routing_status="ok"
else
  routing_status="error"
  failed=1
fi

if [[ "${silent}" -eq 0 ]]; then
  echo "Publishing test message..."
fi
EXCHANGE="${GRANT_EXCHANGE}" ROUTING_KEY="${ROUTING_KEY:-}" \
  "${ROOT}/scripts/publish_test_message.sh" --silent >/dev/null || publish_status="error"
if [[ "${publish_status}" == "error" ]]; then
  failed=1
fi

counts_before_json=$("${ROOT}/scripts/count_queue_messages.sh" --json 2>/dev/null || printf '%s' '[]')

if [[ "${silent}" -eq 0 ]]; then
  echo "Queue counts:"
  "${ROOT}/scripts/count_queue_messages.sh"
fi

if [[ "${silent}" -eq 0 ]]; then
  echo "Consume from grant_contracts..."
fi
QUEUE="${CONTRACTS_QUEUE}" "${ROOT}/scripts/consume_test_message.sh" --silent

if [[ "${silent}" -eq 0 ]]; then
  echo "Consume from grant_other_documents..."
fi
QUEUE="${OTHER_QUEUE}" "${ROOT}/scripts/consume_test_message.sh" --silent

counts_after_json=$("${ROOT}/scripts/count_queue_messages.sh" --json 2>/dev/null || printf '%s' '[]')

if [[ "${json_output}" -eq 1 ]]; then
  WAIT_STATUS="${wait_status}" CHECK_STATUS="${check_status}" BOOTSTRAP_STATUS="${bootstrap_status}" \
  VALIDATE_STATUS="${validate_status}" ROUTING_STATUS="${routing_status}" PUBLISH_STATUS="${publish_status}" \
  COUNTS_BEFORE_JSON="${counts_before_json}" COUNTS_AFTER_JSON="${counts_after_json}" FAILED="${failed}" \
  python3 - <<'PY'
import json,os
def load_json(raw, default):
    try:
        return json.loads(raw) if raw.strip() else default
    except json.JSONDecodeError:
        return default

failed=os.environ.get("FAILED","0") == "1"
status="error" if failed else "ok"
counts_before=load_json(os.environ.get("COUNTS_BEFORE_JSON",""), [])
counts_after=load_json(os.environ.get("COUNTS_AFTER_JSON",""), [])
payload={
    "status": status,
    "steps": {
        "wait_rabbitmq": os.environ.get("WAIT_STATUS","error"),
        "check_rabbitmq": os.environ.get("CHECK_STATUS","error"),
        "bootstrap_rabbitmq": os.environ.get("BOOTSTRAP_STATUS","error"),
        "validate_rabbitmq": os.environ.get("VALIDATE_STATUS","error"),
        "test_routing": os.environ.get("ROUTING_STATUS","error"),
        "publish_test_message": os.environ.get("PUBLISH_STATUS","error"),
    },
    "counts_before": counts_before,
    "counts_after": counts_after,
}
print(json.dumps(payload))
PY
  exit "${failed}"
fi

if [[ "${silent}" -eq 0 ]]; then
  echo "Smoke test finished."
fi
