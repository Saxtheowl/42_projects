#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

vhost_enc=$(python3 - <<'PY'
import os,urllib.parse
v=os.environ.get("VHOST","/")
print(urllib.parse.quote(v, safe=""))
PY
)

api() {
  curl -fsS -u "${USER}:${PASS}" -H "Content-Type: application/json" "$@"
}

put_exchange() {
  local name="$1"
  local type="$2"
  api -X PUT "http://${HOST}:${PORT}/api/exchanges/${vhost_enc}/${name}" \
    -d "{\"type\":\"${type}\",\"durable\":true}"
}

put_queue() {
  local name="$1"
  api -X PUT "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${name}" \
    -d '{"durable":true}'
}

bind_queue() {
  local exchange="$1"
  local queue="$2"
  local routing_key="$3"
  api -X POST "http://${HOST}:${PORT}/api/bindings/${vhost_enc}/e/${exchange}/q/${queue}" \
    -d "{\"routing_key\":\"${routing_key}\"}"
}

echo "Configuring exchanges/queues on ${HOST}:${PORT} (vhost: ${VHOST})..."

put_exchange "SOCIAL_ASSISTANCE_EXCHANGE" "fanout"
put_exchange "GRANT_EXCHANGE" "topic"

put_queue "food_application"
put_queue "financial_assistance_application"
put_queue "transportation_costs_application"
put_queue "grant_other_documents"
put_queue "grant_contracts"

bind_queue "SOCIAL_ASSISTANCE_EXCHANGE" "food_application" ""
bind_queue "SOCIAL_ASSISTANCE_EXCHANGE" "financial_assistance_application" ""
bind_queue "SOCIAL_ASSISTANCE_EXCHANGE" "transportation_costs_application" ""

bind_queue "GRANT_EXCHANGE" "grant_other_documents" "grant.#"
bind_queue "GRANT_EXCHANGE" "grant_contracts" "grant.1.*"

echo "RabbitMQ bootstrap complete."
