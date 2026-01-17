#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

QUEUE="${QUEUE:-food_application}"
COUNT="${COUNT:-1}"
ACK_MODE="${ACK_MODE:-ack_requeue_false}"
TRUNCATE="${TRUNCATE:-50000}"

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

body=$(python3 - <<'PY'
import json,os
count=int(os.environ.get("COUNT","1"))
ack=os.environ.get("ACK_MODE","ack_requeue_false")
truncate=int(os.environ.get("TRUNCATE","50000"))
body={
  "count": count,
  "ackmode": ack,
  "encoding": "auto",
  "truncate": truncate
}
print(json.dumps(body))
PY
)

curl -fsS -u "${USER}:${PASS}" \
  -H "Content-Type: application/json" \
  -X POST "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${QUEUE}/get" \
  -d "${body}"

echo
echo "Fetched from queue '${QUEUE}'."
