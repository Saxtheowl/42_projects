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
OUTPUT="${OUTPUT:-raw}"

silent=0
json_output=0
for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/consume_test_message.sh [--help] [--silent] [--json]

Environment:
  QUEUE      Queue name (default: food_application)
  COUNT      Number of messages (default: 1)
  ACK_MODE   ack_requeue_false|ack_requeue_true|ack_requeue_false (default: ack_requeue_false)
  TRUNCATE   Response truncate size (default: 50000)
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

response=$(curl -fsS -u "${USER}:${PASS}" \
  -H "Content-Type: application/json" \
  -X POST "http://${HOST}:${PORT}/api/queues/${vhost_enc}/${QUEUE}/get" \
  -d "${body}")

if [[ "${silent}" -eq 1 ]]; then
  exit 0
fi

if [[ "${json_output}" -eq 1 ]]; then
  printf '%s\n' "${response}"
  exit 0
fi

case "${OUTPUT}" in
  raw)
    printf '%s\n' "${response}"
    ;;
  pretty)
    if command -v jq >/dev/null 2>&1; then
      printf '%s\n' "${response}" | jq .
    else
      echo "jq not found; falling back to raw output." >&2
      printf '%s\n' "${response}"
    fi
    ;;
  *)
    echo "Unknown OUTPUT: ${OUTPUT} (use raw or pretty)" >&2
    exit 1
    ;;
esac

echo "Fetched from queue '${QUEUE}'."
