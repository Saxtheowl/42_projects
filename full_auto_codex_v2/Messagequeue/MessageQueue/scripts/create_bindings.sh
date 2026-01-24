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

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/create_bindings.sh [--help] [--silent] [--json]

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

if [[ "${json_output}" -eq 1 ]]; then
  trap 'printf "%s\n" "{\"status\":\"error\",\"step\":\"create_bindings\"}"' ERR
fi

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

api_put() {
  local path="$1"
  local payload="$2"
  curl -fsS -u "${USER}:${PASS}" \
    -H "Content-Type: application/json" \
    -X PUT "http://${HOST}:${PORT}${path}" \
    -d "${payload}" >/dev/null
}

api_post() {
  local path="$1"
  local payload="$2"
  curl -fsS -u "${USER}:${PASS}" \
    -H "Content-Type: application/json" \
    -X POST "http://${HOST}:${PORT}${path}" \
    -d "${payload}" >/dev/null
}

if [[ "${silent}" -eq 0 ]]; then
  echo "Creating exchanges..."
fi
api_put "/api/exchanges/${vhost_enc}/${SOCIAL_EXCHANGE}" '{"type":"fanout","durable":true}'
api_put "/api/exchanges/${vhost_enc}/${GRANT_EXCHANGE}" '{"type":"topic","durable":true}'

if [[ "${silent}" -eq 0 ]]; then
  echo "Creating queues..."
fi
api_put "/api/queues/${vhost_enc}/${FOOD_QUEUE}" '{"durable":true}'
api_put "/api/queues/${vhost_enc}/${FINANCIAL_QUEUE}" '{"durable":true}'
api_put "/api/queues/${vhost_enc}/${TRANSPORT_QUEUE}" '{"durable":true}'
api_put "/api/queues/${vhost_enc}/${CONTRACTS_QUEUE}" '{"durable":true}'
api_put "/api/queues/${vhost_enc}/${OTHER_QUEUE}" '{"durable":true}'

if [[ "${silent}" -eq 0 ]]; then
  echo "Creating bindings..."
fi
api_post "/api/bindings/${vhost_enc}/e/${SOCIAL_EXCHANGE}/q/${FOOD_QUEUE}" '{"routing_key":""}'
api_post "/api/bindings/${vhost_enc}/e/${SOCIAL_EXCHANGE}/q/${FINANCIAL_QUEUE}" '{"routing_key":""}'
api_post "/api/bindings/${vhost_enc}/e/${SOCIAL_EXCHANGE}/q/${TRANSPORT_QUEUE}" '{"routing_key":""}'
api_post "/api/bindings/${vhost_enc}/e/${GRANT_EXCHANGE}/q/${CONTRACTS_QUEUE}" "{\"routing_key\":\"${CONTRACTS_ROUTING_KEY}\"}"
api_post "/api/bindings/${vhost_enc}/e/${GRANT_EXCHANGE}/q/${OTHER_QUEUE}" "{\"routing_key\":\"${OTHER_ROUTING_KEY}\"}"

if [[ "${silent}" -eq 0 ]]; then
  echo "Bindings created."
fi

if [[ "${json_output}" -eq 1 ]]; then
  printf '%s\n' "{\"status\":\"ok\",\"host\":\"${HOST}\",\"port\":${PORT},\"vhost\":\"${VHOST}\"}"
fi
