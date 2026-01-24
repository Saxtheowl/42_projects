#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

HOST="${RABBITMQ_HOST:-localhost}"
PORT="${RABBITMQ_PORT:-15672}"
USER="${RABBITMQ_USER:-guest}"
PASS="${RABBITMQ_PASS:-guest}"
VHOST="${RABBITMQ_VHOST:-/}"

EXCHANGE="${EXCHANGE:-${GRANT_EXCHANGE:-GRANT_EXCHANGE}}"
ROUTING_KEY="${ROUTING_KEY:-}"
PAYLOAD_FILE="${PAYLOAD_FILE:-docs/sample_student.json}"
CONTENT_TYPE="${CONTENT_TYPE:-application/json}"
MESSAGE_ID="${MESSAGE_ID:-mq-test-$(date +%s)}"
STRICT_GRANT_TYPE="${STRICT_GRANT_TYPE:-0}"

silent=0
json_output=0
dry_run=0
for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/publish_test_message.sh [--help] [--silent] [--json] [--dry-run]

Environment:
  EXCHANGE     Exchange name (default: GRANT_EXCHANGE)
  ROUTING_KEY  Routing key (default: grantType du payload, sinon grant.1.contract)
  PAYLOAD_FILE Payload JSON (default: docs/sample_student.json)
  CONTENT_TYPE Content type (default: application/json)
  MESSAGE_ID   Message id (default: mq-test-<timestamp>)
  STRICT_GRANT_TYPE Strict grantType vs routing key check (default: 0)

Notes:
  - EXCHANGE/ROUTING_KEY accept letters, numbers, dot, underscore, hyphen.
  - PAYLOAD_FILE must be a readable file (valid JSON, not a directory).
  - MESSAGE_ID must not contain whitespace.
  - CONTENT_TYPE must not be only whitespace.
  - With --json, validation errors return status=error.
  - --dry-run validates inputs without calling the HTTP API.
EOF
    exit 0
  elif [[ "${arg}" == "--silent" ]]; then
    silent=1
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
    silent=1
  elif [[ "${arg}" == "--dry-run" ]]; then
    dry_run=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

if ! command -v python3 >/dev/null 2>&1; then
  json_error "python3 is required."
  exit 1
fi

json_error() {
  local message="$1"
  if [[ "${json_output}" -eq 1 ]] && command -v python3 >/dev/null 2>&1; then
    MSG="${message}" python3 - <<'PY'
import json,os
msg=os.environ.get("MSG","")
print(json.dumps({"status":"error","error":msg}))
PY
  else
    echo "${message}" >&2
  fi
}

if [[ -z "${EXCHANGE}" ]]; then
  json_error "EXCHANGE must be non-empty."
  exit 1
fi
if ! [[ "${EXCHANGE}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  json_error "EXCHANGE must use only letters, numbers, dot, underscore, or hyphen."
  exit 1
fi
if [[ ${#EXCHANGE} -gt 255 ]]; then
  json_error "EXCHANGE must be 255 characters or less."
  exit 1
fi
if [[ -z "${CONTENT_TYPE}" ]]; then
  json_error "CONTENT_TYPE must be non-empty."
  exit 1
fi
if [[ "${CONTENT_TYPE//[[:space:]]/}" == "" ]]; then
  json_error "CONTENT_TYPE must not be only whitespace."
  exit 1
fi
if [[ ${#CONTENT_TYPE} -gt 255 ]]; then
  json_error "CONTENT_TYPE must be 255 characters or less."
  exit 1
fi
if [[ -z "${MESSAGE_ID}" ]]; then
  json_error "MESSAGE_ID must be non-empty."
  exit 1
fi
if [[ "${MESSAGE_ID}" =~ [[:space:]] ]]; then
  json_error "MESSAGE_ID must not contain whitespace."
  exit 1
fi
if [[ ${#MESSAGE_ID} -gt 255 ]]; then
  json_error "MESSAGE_ID must be 255 characters or less."
  exit 1
fi

if [[ "${dry_run}" -ne 1 ]]; then
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required." >&2
    exit 1
  fi
fi

resolved_payload=""
if [[ -d "${PAYLOAD_FILE}" ]]; then
  json_error "Payload file is a directory: ${PAYLOAD_FILE}"
  exit 1
elif [[ -f "${PAYLOAD_FILE}" ]]; then
  resolved_payload="${PAYLOAD_FILE}"
elif [[ -d "${ROOT_DIR}/${PAYLOAD_FILE}" ]]; then
  json_error "Payload file is a directory: ${PAYLOAD_FILE}"
  exit 1
elif [[ -f "${ROOT_DIR}/${PAYLOAD_FILE}" ]]; then
  resolved_payload="${ROOT_DIR}/${PAYLOAD_FILE}"
else
  json_error "Payload file not found: ${PAYLOAD_FILE}"
  exit 1
fi
PAYLOAD_FILE="${resolved_payload}"
if [[ ! -r "${PAYLOAD_FILE}" ]]; then
  json_error "Payload file is not readable: ${PAYLOAD_FILE}"
  exit 1
fi

vhost_enc=$(python3 - <<'PY'
import os,urllib.parse
v=os.environ.get("VHOST","/")
print(urllib.parse.quote(v, safe=""))
PY
)

if ! payload_json=$(python3 - "${PAYLOAD_FILE}" <<'PY'
import json,sys
path=sys.argv[1]
try:
    with open(path, "r", encoding="utf-8") as handle:
        data=json.load(handle)
except json.JSONDecodeError:
    print(f"Payload file is not valid JSON: {path}", file=sys.stderr)
    sys.exit(1)
except OSError:
    print(f"Failed to read payload JSON: {path}", file=sys.stderr)
    sys.exit(1)
if "grantType" in data:
    data.setdefault("metadata", {})["grantType"] = data["grantType"]
print(json.dumps(data))
PY
); then
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"error\",\"error\":\"Payload file is not valid JSON: ${PAYLOAD_FILE}\"}"
  fi
  exit 1
fi

if [[ -z "${ROUTING_KEY}" ]]; then
  ROUTING_KEY=$(python3 - "${payload_json}" <<'PY'
import json,sys
payload=json.loads(sys.argv[1])
print(payload.get("grantType",""))
PY
)
fi
if [[ -z "${ROUTING_KEY}" ]]; then
  ROUTING_KEY="grant.1.contract"
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"warning\",\"warning\":\"ROUTING_KEY not set and payload has no grantType; using ${ROUTING_KEY}.\"}"
  else
    echo "Warning: ROUTING_KEY not set and payload has no grantType; using ${ROUTING_KEY}." >&2
  fi
fi
if [[ -n "${ROUTING_KEY}" && ! "${ROUTING_KEY}" =~ ^[A-Za-z0-9._-]+$ ]]; then
  json_error "ROUTING_KEY must use only letters, numbers, dot, underscore, or hyphen."
  exit 1
fi
if [[ -n "${ROUTING_KEY}" && ${#ROUTING_KEY} -gt 255 ]]; then
  json_error "ROUTING_KEY must be 255 characters or less."
  exit 1
fi
export ROUTING_KEY

payload_grant_type=$(python3 - "${payload_json}" <<'PY'
import json,sys
payload=json.loads(sys.argv[1])
print(payload.get("grantType",""))
PY
)
if [[ -n "${payload_grant_type}" && -n "${ROUTING_KEY}" && "${payload_grant_type}" != "${ROUTING_KEY}" ]]; then
  if [[ "${STRICT_GRANT_TYPE}" == "1" ]]; then
    json_error "Error: ROUTING_KEY (${ROUTING_KEY}) differs from grantType (${payload_grant_type})."
    exit 1
  fi
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"warning\",\"warning\":\"ROUTING_KEY (${ROUTING_KEY}) differs from grantType (${payload_grant_type}).\"}"
  else
    echo "Warning: ROUTING_KEY (${ROUTING_KEY}) differs from grantType (${payload_grant_type})." >&2
  fi
fi

body=$(python3 - "${payload_json}" <<'PY'
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
)

if [[ "${dry_run}" -eq 1 ]]; then
  if [[ "${json_output}" -eq 1 ]]; then
    printf '%s\n' "{\"status\":\"dry_run\",\"exchange\":\"${EXCHANGE}\",\"routing_key\":\"${ROUTING_KEY}\",\"payload_file\":\"${PAYLOAD_FILE}\",\"content_type\":\"${CONTENT_TYPE}\",\"message_id\":\"${MESSAGE_ID}\"}"
  elif [[ "${silent}" -eq 0 ]]; then
    echo "Dry run: EXCHANGE=${EXCHANGE} ROUTING_KEY=${ROUTING_KEY}"
    echo "PAYLOAD_FILE=${PAYLOAD_FILE} CONTENT_TYPE=${CONTENT_TYPE} MESSAGE_ID=${MESSAGE_ID}"
  fi
  exit 0
fi

curl -fsS -u "${USER}:${PASS}" \
  -H "Content-Type: application/json" \
  -X POST "http://${HOST}:${PORT}/api/exchanges/${vhost_enc}/${EXCHANGE}/publish" \
  -d "${body}" >/dev/null

if [[ "${json_output}" -eq 1 ]]; then
  printf '%s\n' "{\"status\":\"ok\",\"exchange\":\"${EXCHANGE}\",\"routing_key\":\"${ROUTING_KEY}\"}"
elif [[ "${silent}" -eq 0 ]]; then
  echo "Published payload to ${EXCHANGE} (routing_key='${ROUTING_KEY}')."
fi
