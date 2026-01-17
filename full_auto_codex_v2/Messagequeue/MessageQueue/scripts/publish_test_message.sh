#!/usr/bin/env bash
set -euo pipefail

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

EXCHANGE="${EXCHANGE:-GRANT_EXCHANGE}"
ROUTING_KEY="${ROUTING_KEY:-grant.1.contract}"
PAYLOAD_FILE="${PAYLOAD_FILE:-docs/sample_student.json}"
CONTENT_TYPE="${CONTENT_TYPE:-application/json}"
MESSAGE_ID="${MESSAGE_ID:-mq-test-$(date +%s)}"

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "python3 is required." >&2
  exit 1
fi
if [[ ! -f "${PAYLOAD_FILE}" ]]; then
  echo "Payload file not found: ${PAYLOAD_FILE}" >&2
  exit 1
fi

vhost_enc=$(python3 - <<'PY'
import os,urllib.parse
v=os.environ.get("VHOST","/")
print(urllib.parse.quote(v, safe=""))
PY
)

payload_json=$(python3 - <<'PY'
import json,sys
path=sys.argv[1]
data=json.load(open(path))
if "grantType" in data and "grantType" not in data.get("metadata", {}):
    data.setdefault("metadata", {})["grantType"] = data["grantType"]
print(json.dumps(data))
PY
"${PAYLOAD_FILE}")

body=$(python3 - <<'PY'
import json,sys,os
payload=sys.argv[1]
rk=os.environ.get("ROUTING_KEY","")
content_type=os.environ.get("CONTENT_TYPE","application/json")
message_id=os.environ.get("MESSAGE_ID","")
body={
  "properties": {"content_type": content_type, "message_id": message_id},
  "routing_key": rk,
  "payload": payload,
  "payload_encoding": "string"
}
print(json.dumps(body))
PY
"${payload_json}")

curl -fsS -u "${USER}:${PASS}" \
  -H "Content-Type: application/json" \
  -X POST "http://${HOST}:${PORT}/api/exchanges/${vhost_enc}/${EXCHANGE}/publish" \
  -d "${body}" >/dev/null

echo "Published payload to ${EXCHANGE} (routing_key='${ROUTING_KEY}')."
