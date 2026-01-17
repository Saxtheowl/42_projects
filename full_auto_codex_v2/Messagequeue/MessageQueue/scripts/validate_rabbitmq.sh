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

EXCHANGES="${exchanges_json}" QUEUES="${queues_json}" BINDINGS="${bindings_json}" python3 - <<'PY'
import json,sys,os
exchanges=json.loads(os.environ["EXCHANGES"])
queues=json.loads(os.environ["QUEUES"])
bindings=json.loads(os.environ["BINDINGS"])
ex_names={e["name"] for e in exchanges}
q_names={q["name"] for q in queues}
bind_set={(b.get("source"), b.get("destination"), b.get("routing_key")) for b in bindings}

required_ex={"SOCIAL_ASSISTANCE_EXCHANGE","GRANT_EXCHANGE"}
required_q={
    "food_application",
    "financial_assistance_application",
    "transportation_costs_application",
    "grant_other_documents",
    "grant_contracts",
}
required_bindings={
    ("SOCIAL_ASSISTANCE_EXCHANGE","food_application",""),
    ("SOCIAL_ASSISTANCE_EXCHANGE","financial_assistance_application",""),
    ("SOCIAL_ASSISTANCE_EXCHANGE","transportation_costs_application",""),
    ("GRANT_EXCHANGE","grant_other_documents","grant.#"),
    ("GRANT_EXCHANGE","grant_contracts","grant.1.*"),
}
missing_ex=required_ex - ex_names
missing_q=required_q - q_names
missing_b=required_bindings - bind_set
if missing_ex or missing_q or missing_b:
    if missing_ex:
        print("Missing exchanges:", ", ".join(sorted(missing_ex)), file=sys.stderr)
    if missing_q:
        print("Missing queues:", ", ".join(sorted(missing_q)), file=sys.stderr)
    if missing_b:
        print("Missing bindings:", ", ".join(sorted(f"{s}->{d}({k})" for s,d,k in missing_b)), file=sys.stderr)
    sys.exit(1)
print("RabbitMQ topology OK.")
PY
