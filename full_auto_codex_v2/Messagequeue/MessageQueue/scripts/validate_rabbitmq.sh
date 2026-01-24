#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"
silent=0
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/validate_rabbitmq.sh [--help] [--silent] [--json]

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

fetch() {
  curl -fsS -u "${USER}:${PASS}" "$1"
}

exchanges_json=$(fetch "http://${HOST}:${PORT}/api/exchanges/${vhost_enc}")
queues_json=$(fetch "http://${HOST}:${PORT}/api/queues/${vhost_enc}")
bindings_json=$(fetch "http://${HOST}:${PORT}/api/bindings/${vhost_enc}")

EXCHANGES="${exchanges_json}" QUEUES="${queues_json}" BINDINGS="${bindings_json}" \
SOCIAL_EXCHANGE="${SOCIAL_EXCHANGE:-SOCIAL_ASSISTANCE_EXCHANGE}" \
GRANT_EXCHANGE="${GRANT_EXCHANGE:-GRANT_EXCHANGE}" \
FOOD_QUEUE="${FOOD_QUEUE:-food_application}" \
FINANCIAL_QUEUE="${FINANCIAL_QUEUE:-financial_assistance_application}" \
TRANSPORT_QUEUE="${TRANSPORT_QUEUE:-transportation_costs_application}" \
CONTRACTS_QUEUE="${CONTRACTS_QUEUE:-grant_contracts}" \
OTHER_QUEUE="${OTHER_QUEUE:-grant_other_documents}" \
CONTRACTS_ROUTING_KEY="${CONTRACTS_ROUTING_KEY:-grant.*.contract}" \
OTHER_ROUTING_KEY="${OTHER_ROUTING_KEY:-grant.*}" \
SILENT="${silent}" \
JSON_OUTPUT="${json_output}" \
python3 - <<'PY'
import json,sys,os
exchanges=json.loads(os.environ["EXCHANGES"])
queues=json.loads(os.environ["QUEUES"])
bindings=json.loads(os.environ["BINDINGS"])
ex_names={e["name"] for e in exchanges}
q_names={q["name"] for q in queues}
bind_set={(b.get("source"), b.get("destination"), b.get("routing_key")) for b in bindings}

social_exchange=os.environ.get("SOCIAL_EXCHANGE","SOCIAL_ASSISTANCE_EXCHANGE")
grant_exchange=os.environ.get("GRANT_EXCHANGE","GRANT_EXCHANGE")
food_queue=os.environ.get("FOOD_QUEUE","food_application")
financial_queue=os.environ.get("FINANCIAL_QUEUE","financial_assistance_application")
transport_queue=os.environ.get("TRANSPORT_QUEUE","transportation_costs_application")
contracts_queue=os.environ.get("CONTRACTS_QUEUE","grant_contracts")
other_queue=os.environ.get("OTHER_QUEUE","grant_other_documents")
contracts_routing_key=os.environ.get("CONTRACTS_ROUTING_KEY","grant.*.contract")
other_routing_key=os.environ.get("OTHER_ROUTING_KEY","grant.*")

required_ex={social_exchange, grant_exchange}
required_q={food_queue, financial_queue, transport_queue, other_queue, contracts_queue}
required_bindings={
    (social_exchange, food_queue, ""),
    (social_exchange, financial_queue, ""),
    (social_exchange, transport_queue, ""),
    (grant_exchange, other_queue, other_routing_key),
    (grant_exchange, contracts_queue, contracts_routing_key),
}
missing_ex=required_ex - ex_names
missing_q=required_q - q_names
missing_b=required_bindings - bind_set
json_output = os.environ.get("JSON_OUTPUT") == "1"
if missing_ex or missing_q or missing_b:
    if json_output:
        print(json.dumps({
            "status": "error",
            "missing_exchanges": sorted(missing_ex),
            "missing_queues": sorted(missing_q),
            "missing_bindings": sorted(f"{s}->{d}({k})" for s,d,k in missing_b),
        }))
    else:
        if missing_ex:
            print("Missing exchanges:", ", ".join(sorted(missing_ex)), file=sys.stderr)
        if missing_q:
            print("Missing queues:", ", ".join(sorted(missing_q)), file=sys.stderr)
        if missing_b:
            print("Missing bindings:", ", ".join(sorted(f"{s}->{d}({k})" for s,d,k in missing_b)), file=sys.stderr)
    sys.exit(1)
if json_output:
    print(json.dumps({"status": "ok"}))
elif os.environ.get("SILENT") != "1":
    print("RabbitMQ topology OK.")
PY
