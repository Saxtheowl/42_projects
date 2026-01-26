#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/status_report.sh [--help] [--silent] [--json]

Environment:
  QUEUE_FILTER        CSV filter for queues
  EXCHANGE_FILTER     CSV filter for exchanges
  SOURCE_FILTER       CSV filter for binding sources
  DESTINATION_FILTER  CSV filter for binding destinations
  ROUTING_KEY_FILTER  CSV filter for routing keys
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

"${ROOT}/scripts/check_prereqs.sh" >/dev/null

if [[ "${silent}" -eq 0 ]]; then
  printf '%s\n' "RabbitMQ status report" "======================" ""
fi

if "${ROOT}/scripts/check_rabbitmq.sh" >/dev/null 2>&1; then
  if [[ "${silent}" -eq 0 ]]; then
    echo "[ok] management API reachable"
  fi
else
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' '{"status":"error","error":"management API unreachable"}'
  else
    echo "[missing] management API unreachable" >&2
  fi
  exit 1
fi

QUEUE_FILTER="${QUEUE_FILTER:-}"
EXCHANGE_FILTER="${EXCHANGE_FILTER:-}"
SOURCE_FILTER="${SOURCE_FILTER:-}"
DESTINATION_FILTER="${DESTINATION_FILTER:-}"
ROUTING_KEY_FILTER="${ROUTING_KEY_FILTER:-}"

if [[ -n "${QUEUE_FILTER}${EXCHANGE_FILTER}${SOURCE_FILTER}${DESTINATION_FILTER}${ROUTING_KEY_FILTER}" ]]; then
  if [[ "${silent}" -eq 0 ]]; then
    echo
    echo "Filters:"
    [[ -n "${QUEUE_FILTER}" ]] && echo "  QUEUE_FILTER=${QUEUE_FILTER}"
    [[ -n "${EXCHANGE_FILTER}" ]] && echo "  EXCHANGE_FILTER=${EXCHANGE_FILTER}"
    [[ -n "${SOURCE_FILTER}" ]] && echo "  SOURCE_FILTER=${SOURCE_FILTER}"
    [[ -n "${DESTINATION_FILTER}" ]] && echo "  DESTINATION_FILTER=${DESTINATION_FILTER}"
    [[ -n "${ROUTING_KEY_FILTER}" ]] && echo "  ROUTING_KEY_FILTER=${ROUTING_KEY_FILTER}"
  fi
fi

if [[ "${json_output}" -eq 1 ]]; then
  queues_json=$(QUEUES="${QUEUE_FILTER}" "${ROOT}/scripts/count_queue_messages.sh" --json)
  exchanges_json=$(EXCHANGES="${EXCHANGE_FILTER}" "${ROOT}/scripts/list_exchanges.sh" --json)
  bindings_json=$(SOURCES="${SOURCE_FILTER}" DESTINATIONS="${DESTINATION_FILTER}" ROUTING_KEYS="${ROUTING_KEY_FILTER}" \
    "${ROOT}/scripts/list_bindings.sh" --json)
  QUEUE_FILTER="${QUEUE_FILTER}" EXCHANGE_FILTER="${EXCHANGE_FILTER}" SOURCE_FILTER="${SOURCE_FILTER}" \
  DESTINATION_FILTER="${DESTINATION_FILTER}" ROUTING_KEY_FILTER="${ROUTING_KEY_FILTER}" \
  QUEUES_JSON="${queues_json}" EXCHANGES_JSON="${exchanges_json}" BINDINGS_JSON="${bindings_json}" \
  python3 - <<'PY'
import json,os
def safe_load(raw, default):
    try:
        return json.loads(raw) if raw.strip() else default
    except json.JSONDecodeError:
        return default

filters={
    "queue_filter": os.environ.get("QUEUE_FILTER",""),
    "exchange_filter": os.environ.get("EXCHANGE_FILTER",""),
    "source_filter": os.environ.get("SOURCE_FILTER",""),
    "destination_filter": os.environ.get("DESTINATION_FILTER",""),
    "routing_key_filter": os.environ.get("ROUTING_KEY_FILTER",""),
}
payload={
    "status": "ok",
    "filters": filters,
    "queues": safe_load(os.environ.get("QUEUES_JSON",""), []),
    "exchanges": safe_load(os.environ.get("EXCHANGES_JSON",""), []),
    "bindings": safe_load(os.environ.get("BINDINGS_JSON",""), []),
}
print(json.dumps(payload))
PY
  exit 0
fi

if [[ "${silent}" -eq 0 ]]; then
  echo
  printf '%s\n' "Queues:" "------"
fi
QUEUES="${QUEUE_FILTER}" "${ROOT}/scripts/count_queue_messages.sh"

if [[ "${silent}" -eq 0 ]]; then
  echo
  printf '%s\n' "Exchanges:" "---------"
fi
EXCHANGES="${EXCHANGE_FILTER}" "${ROOT}/scripts/list_exchanges.sh"

if [[ "${silent}" -eq 0 ]]; then
  echo
  printf '%s\n' "Bindings:" "---------"
fi
SOURCES="${SOURCE_FILTER}" DESTINATIONS="${DESTINATION_FILTER}" ROUTING_KEYS="${ROUTING_KEY_FILTER}" \
  "${ROOT}/scripts/list_bindings.sh"
