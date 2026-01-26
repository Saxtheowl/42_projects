#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

SOCIAL_EXCHANGE="${SOCIAL_EXCHANGE:-SOCIAL_ASSISTANCE_EXCHANGE}"
GRANT_EXCHANGE="${GRANT_EXCHANGE:-GRANT_EXCHANGE}"

FOOD_QUEUE="${FOOD_QUEUE:-food_application}"
FINANCIAL_QUEUE="${FINANCIAL_QUEUE:-financial_assistance_application}"
TRANSPORT_QUEUE="${TRANSPORT_QUEUE:-transportation_costs_application}"
CONTRACTS_QUEUE="${CONTRACTS_QUEUE:-grant_contracts}"
OTHER_QUEUE="${OTHER_QUEUE:-grant_other_documents}"

CONTRACTS_ROUTING_KEY="${CONTRACTS_ROUTING_KEY:-grant.*.contract}"
OTHER_ROUTING_KEY="${OTHER_ROUTING_KEY:-grant.*}"
silent=0
json_output=0

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  ROOT="${ROOT_OVERRIDE}"
fi

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/bootstrap_rabbitmq.sh [--help] [--silent] [--json]

Environment:
  SOCIAL_EXCHANGE     Fanout exchange name
  GRANT_EXCHANGE      Topic exchange name
  FOOD_QUEUE          Queue name
  FINANCIAL_QUEUE     Queue name
  TRANSPORT_QUEUE     Queue name
  CONTRACTS_QUEUE     Queue name
  OTHER_QUEUE         Queue name
  CONTRACTS_ROUTING_KEY  Routing key pattern
  OTHER_ROUTING_KEY      Routing key pattern
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

json_error() {
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' '{"status":"error","step":"bootstrap"}'
  fi
}

if ! command -v curl >/dev/null 2>&1; then
  if [[ "${json_output}" -eq 1 ]]; then
    json_error
  else
    echo "curl is required." >&2
  fi
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  if [[ "${json_output}" -eq 1 ]]; then
    json_error
  else
    echo "python3 is required." >&2
  fi
  exit 1
fi

vhost_enc=$(python3 - <<'PY'
import os,urllib.parse
v=os.environ.get("VHOST","/")
print(urllib.parse.quote(v, safe=""))
PY
) || { json_error; exit 1; }

api() {
  curl -fsS -u "${USER}:${PASS}" -H "Content-Type: application/json" "$@"
}

put_exchange() {
  local name="$1"
  local type="$2"
  api -X PUT "http://${HOST}:${PORT}/api/exchanges/${vhost_enc}/${name}" \
    -d "{\"type\":\"${type}\",\"durable\":true}" || { json_error; return 1; }
}

put_queue() {
  local name="$1"
  api -X PUT "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${name}" \
    -d '{"durable":true}' || { json_error; return 1; }
}

bind_queue() {
  local exchange="$1"
  local queue="$2"
  local routing_key="$3"
  api -X POST "http://${HOST}:${PORT}/api/bindings/${vhost_enc}/e/${exchange}/q/${queue}" \
    -d "{\"routing_key\":\"${routing_key}\"}" || { json_error; return 1; }
}

if [[ "${silent}" -eq 0 ]]; then
  echo "Configuring exchanges/queues on ${HOST}:${PORT} (vhost: ${VHOST})..."
fi

if [[ -n "${ROOT_OVERRIDE:-}" ]]; then
  "${ROOT}/scripts/check_rabbitmq.sh" --silent >/dev/null
fi

put_exchange "${SOCIAL_EXCHANGE}" "fanout"
put_exchange "${GRANT_EXCHANGE}" "topic"

put_queue "${FOOD_QUEUE}"
put_queue "${FINANCIAL_QUEUE}"
put_queue "${TRANSPORT_QUEUE}"
put_queue "${OTHER_QUEUE}"
put_queue "${CONTRACTS_QUEUE}"

bind_queue "${SOCIAL_EXCHANGE}" "${FOOD_QUEUE}" ""
bind_queue "${SOCIAL_EXCHANGE}" "${FINANCIAL_QUEUE}" ""
bind_queue "${SOCIAL_EXCHANGE}" "${TRANSPORT_QUEUE}" ""

bind_queue "${GRANT_EXCHANGE}" "${OTHER_QUEUE}" "${OTHER_ROUTING_KEY}"
bind_queue "${GRANT_EXCHANGE}" "${CONTRACTS_QUEUE}" "${CONTRACTS_ROUTING_KEY}"

if [[ "${silent}" -eq 0 ]]; then
  echo "RabbitMQ bootstrap complete."
fi

if [[ "${json_output}" -eq 1 ]]; then
  printf '%s\n' "{\"status\":\"ok\",\"host\":\"${HOST}\",\"port\":${PORT},\"vhost\":\"${VHOST}\"}"
fi
