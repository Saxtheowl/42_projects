#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/publish_test_message.sh"
json_output=0

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'USAGE'
Usage: ./scripts/test_publish_test_message.sh [--help] [--json]

Runs dry-run tests for publish_test_message.sh.
USAGE
    exit 0
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

payload_file=$(mktemp)
payload_dir=$(mktemp -d)
unreadable_payload=$(mktemp)
invalid_payload=$(mktemp)
cleanup() {
  rm -f "${payload_file}"
  rm -f "${unreadable_payload}"
  rm -f "${invalid_payload}"
  rm -rf "${payload_dir}"
}
trap cleanup EXIT

cat > "${payload_file}" <<'JSON'
{
  "grantType": "grant.9.test",
  "studentId": "STU-99",
  "amount": 123
}
JSON

failed=0
help_status="ok"
help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "--dry-run"; then
  echo "Expected --help to mention --dry-run." >&2
  help_status="error"
  failed=1
fi
if ! printf '%s' "${help_output}" | rg -q -- "status=error"; then
  echo "Expected --help to mention status=error in --json mode." >&2
  help_status="error"
  failed=1
fi
if ! printf '%s' "${help_output}" | rg -q -- "valid JSON"; then
  echo "Expected --help to mention valid JSON." >&2
  help_status="error"
  failed=1
fi
if ! printf '%s' "${help_output}" | rg -q -- "MESSAGE_ID must not contain whitespace"; then
  echo "Expected --help to mention MESSAGE_ID whitespace." >&2
  help_status="error"
  failed=1
fi
missing_payload="ok"
if PAYLOAD_FILE="docs/nope.json" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected missing PAYLOAD_FILE to fail." >&2
  missing_payload="error"
  failed=1
fi
missing_payload_json_status="ok"
missing_payload_json=$(PAYLOAD_FILE="docs/nope.json" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! MISSING_PAYLOAD_JSON="${missing_payload_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("MISSING_PAYLOAD_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for missing payload", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for missing payload", file=sys.stderr)
    sys.exit(1)
if "Payload file not found" not in data.get("error",""):
    print("Expected error message for missing payload", file=sys.stderr)
    sys.exit(1)
PY
then
  missing_payload_json_status="error"
  failed=1
fi
invalid_json_status="ok"
printf '%s\n' '{bad json' > "${invalid_payload}"
invalid_json_status_code=0
invalid_json_output=$(PAYLOAD_FILE="${invalid_payload}" "${SCRIPT}" --dry-run 2>&1) || invalid_json_status_code=$?
if printf '%s' "${invalid_json_output}" | rg -q "Payload file is not valid JSON"; then
  :
else
  echo "Expected invalid JSON payload error message." >&2
  invalid_json_status="error"
  failed=1
fi
if ! printf '%s' "${invalid_json_output}" | rg -q -- "${invalid_payload}"; then
  echo "Expected invalid JSON error to include payload path." >&2
  invalid_json_status="error"
  failed=1
fi
if [[ "${invalid_json_status_code}" -eq 0 ]]; then
  echo "Expected invalid JSON payload to fail." >&2
  invalid_json_status="error"
  failed=1
elif [[ -z "${invalid_json_output}" ]]; then
  echo "Expected invalid JSON payload to fail." >&2
  invalid_json_status="error"
  failed=1
fi
invalid_json_json_status="ok"
invalid_json_json_output=$(PAYLOAD_FILE="${invalid_payload}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! INVALID_JSON_JSON="${invalid_json_json_output}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("INVALID_JSON_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for invalid payload", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for invalid payload", file=sys.stderr)
    sys.exit(1)
if "Payload file is not valid JSON" not in data.get("error",""):
    print("Expected error message for invalid payload", file=sys.stderr)
    sys.exit(1)
PY
then
  invalid_json_json_status="error"
  failed=1
fi
invalid_exchange_status="ok"
if EXCHANGE="bad exchange" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected invalid EXCHANGE to fail." >&2
  invalid_exchange_status="error"
  failed=1
fi
invalid_exchange_json_status="ok"
invalid_exchange_json=$(EXCHANGE="bad exchange" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! INVALID_EXCHANGE_JSON="${invalid_exchange_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("INVALID_EXCHANGE_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for invalid EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for invalid EXCHANGE", file=sys.stderr)
    sys.exit(1)
if "EXCHANGE must use only letters" not in data.get("error",""):
    print("Expected EXCHANGE error message in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  invalid_exchange_json_status="error"
  failed=1
fi
invalid_routing_status="ok"
if ROUTING_KEY="bad key" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected invalid ROUTING_KEY to fail." >&2
  invalid_routing_status="error"
  failed=1
fi
invalid_routing_json_status="ok"
invalid_routing_json=$(ROUTING_KEY="bad key" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! INVALID_ROUTING_JSON="${invalid_routing_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("INVALID_ROUTING_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for invalid ROUTING_KEY", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for invalid ROUTING_KEY", file=sys.stderr)
    sys.exit(1)
if "ROUTING_KEY must use only letters" not in data.get("error",""):
    print("Expected ROUTING_KEY error message in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  invalid_routing_json_status="error"
  failed=1
fi
message_id_whitespace_status="ok"
if MESSAGE_ID=$'bad\t\nid' PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected MESSAGE_ID with whitespace to fail." >&2
  message_id_whitespace_status="error"
  failed=1
fi
message_id_whitespace_json_status="ok"
message_id_whitespace_json=$(MESSAGE_ID=$'bad\t\nid' PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! MESSAGE_ID_WS_JSON="${message_id_whitespace_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("MESSAGE_ID_WS_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for MESSAGE_ID whitespace", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for MESSAGE_ID whitespace", file=sys.stderr)
    sys.exit(1)
if "MESSAGE_ID must not contain whitespace" not in data.get("error",""):
    print("Expected MESSAGE_ID error message in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  message_id_whitespace_json_status="error"
  failed=1
fi
empty_message_id_status="ok"
empty_message_id_json=$(MESSAGE_ID="" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null)
EMPTY_MESSAGE_ID_JSON="${empty_message_id_json}" python3 - <<'PY'
import json,os,sys
data=json.loads(os.environ["EMPTY_MESSAGE_ID_JSON"])
message_id=data.get("message_id","")
if not message_id.startswith("mq-test-"):
    print("Expected default MESSAGE_ID to start with mq-test-", file=sys.stderr)
    sys.exit(1)
PY
if [[ $? -ne 0 ]]; then
  empty_message_id_status="error"
  failed=1
fi
empty_content_type_status="ok"
empty_content_type_json=$(CONTENT_TYPE="" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null)
EMPTY_CONTENT_TYPE_JSON="${empty_content_type_json}" python3 - <<'PY'
import json,os,sys
data=json.loads(os.environ["EMPTY_CONTENT_TYPE_JSON"])
if data.get("content_type") != "application/json":
    print("Expected default CONTENT_TYPE to be application/json", file=sys.stderr)
    sys.exit(1)
PY
if [[ $? -ne 0 ]]; then
  empty_content_type_status="error"
  failed=1
fi
whitespace_content_type_status="ok"
if CONTENT_TYPE=$' \t\n' PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected whitespace CONTENT_TYPE to fail." >&2
  whitespace_content_type_status="error"
  failed=1
fi
whitespace_content_type_json_status="ok"
whitespace_content_type_json=$(CONTENT_TYPE=$' \t\n' PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! WHITESPACE_CONTENT_TYPE_JSON="${whitespace_content_type_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("WHITESPACE_CONTENT_TYPE_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for CONTENT_TYPE whitespace", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for CONTENT_TYPE whitespace", file=sys.stderr)
    sys.exit(1)
if "CONTENT_TYPE must not be only whitespace" not in data.get("error",""):
    print("Expected CONTENT_TYPE error message in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  whitespace_content_type_json_status="error"
  failed=1
fi
long_content_type_status="ok"
long_content_type="ct_$(python3 - <<'PY'
print("z" * 300)
PY
)"
if CONTENT_TYPE="${long_content_type}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected long CONTENT_TYPE to fail." >&2
  long_content_type_status="error"
  failed=1
fi
long_content_type_json_status="ok"
long_content_type_json=$(CONTENT_TYPE="${long_content_type}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! LONG_CONTENT_TYPE_JSON="${long_content_type_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("LONG_CONTENT_TYPE_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for long CONTENT_TYPE", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for long CONTENT_TYPE", file=sys.stderr)
    sys.exit(1)
if "CONTENT_TYPE must be 255 characters or less." not in data.get("error",""):
    print("Expected CONTENT_TYPE length error in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  long_content_type_json_status="error"
  failed=1
fi
long_exchange_status="ok"
long_exchange="ex_$(python3 - <<'PY'
print("x" * 300)
PY
)"
if EXCHANGE="${long_exchange}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected long EXCHANGE to fail." >&2
  long_exchange_status="error"
  failed=1
fi
long_exchange_json_status="ok"
long_exchange_json=$(EXCHANGE="${long_exchange}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! LONG_EXCHANGE_JSON="${long_exchange_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("LONG_EXCHANGE_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for long EXCHANGE", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for long EXCHANGE", file=sys.stderr)
    sys.exit(1)
if "EXCHANGE must be 255 characters or less." not in data.get("error",""):
    print("Expected EXCHANGE length error in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  long_exchange_json_status="error"
  failed=1
fi
long_routing_status="ok"
long_routing="rk_$(python3 - <<'PY'
print("y" * 300)
PY
)"
if ROUTING_KEY="${long_routing}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected long ROUTING_KEY to fail." >&2
  long_routing_status="error"
  failed=1
fi
long_routing_json_status="ok"
long_routing_json=$(ROUTING_KEY="${long_routing}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! LONG_ROUTING_JSON="${long_routing_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("LONG_ROUTING_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for long ROUTING_KEY", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for long ROUTING_KEY", file=sys.stderr)
    sys.exit(1)
if "ROUTING_KEY must be 255 characters or less." not in data.get("error",""):
    print("Expected ROUTING_KEY length error in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  long_routing_json_status="error"
  failed=1
fi
long_message_id_status="ok"
long_message_id="msg_$(python3 - <<'PY'
print("m" * 300)
PY
)"
if MESSAGE_ID="${long_message_id}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected long MESSAGE_ID to fail." >&2
  long_message_id_status="error"
  failed=1
fi
long_message_id_json_status="ok"
long_message_id_json=$(MESSAGE_ID="${long_message_id}" PAYLOAD_FILE="${payload_file}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! LONG_MESSAGE_ID_JSON="${long_message_id_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("LONG_MESSAGE_ID_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for long MESSAGE_ID", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for long MESSAGE_ID", file=sys.stderr)
    sys.exit(1)
if "MESSAGE_ID must be 255 characters or less." not in data.get("error",""):
    print("Expected MESSAGE_ID length error in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  long_message_id_json_status="error"
  failed=1
fi
unreadable_payload_status="ok"
chmod 000 "${unreadable_payload}"
if PAYLOAD_FILE="${unreadable_payload}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected unreadable PAYLOAD_FILE to fail." >&2
  unreadable_payload_status="error"
  failed=1
fi
unreadable_payload_json_status="ok"
unreadable_payload_json=$(PAYLOAD_FILE="${unreadable_payload}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! UNREADABLE_PAYLOAD_JSON="${unreadable_payload_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("UNREADABLE_PAYLOAD_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for unreadable payload", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for unreadable payload", file=sys.stderr)
    sys.exit(1)
if "Payload file is not readable" not in data.get("error",""):
    print("Expected unreadable payload error in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  unreadable_payload_json_status="error"
  failed=1
fi
chmod 644 "${unreadable_payload}"
directory_payload_status="ok"
if PAYLOAD_FILE="${payload_dir}" "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected directory PAYLOAD_FILE to fail." >&2
  directory_payload_status="error"
  failed=1
fi
directory_payload_json_status="ok"
directory_payload_json=$(PAYLOAD_FILE="${payload_dir}" "${SCRIPT}" --dry-run --json 2>/dev/null || true)
if ! DIRECTORY_PAYLOAD_JSON="${directory_payload_json}" python3 - <<'PY'
import json,os,sys
raw=os.environ.get("DIRECTORY_PAYLOAD_JSON","")
try:
    data=json.loads(raw)
except Exception:
    print("Expected JSON error output for directory payload", file=sys.stderr)
    sys.exit(1)
if data.get("status") != "error":
    print("Expected status error for directory payload", file=sys.stderr)
    sys.exit(1)
if "Payload file is a directory" not in data.get("error",""):
    print("Expected directory payload error in JSON", file=sys.stderr)
    sys.exit(1)
PY
then
  directory_payload_json_status="error"
  failed=1
fi

resolved_json=$(
  cd /tmp
  PAYLOAD_FILE="docs/sample_student.json" "${SCRIPT}" --dry-run --json
)
resolve_status="ok"
RESOLVED_PAYLOAD="${ROOT_DIR}/docs/sample_student.json" RESOLVED_JSON="${resolved_json}" python3 - <<'PY'
import json,os,sys
payload=os.environ["RESOLVED_PAYLOAD"]
data=json.loads(os.environ["RESOLVED_JSON"])
if data.get("payload_file") != payload:
    print("payload_file not resolved to repo root", file=sys.stderr)
    sys.exit(1)
PY
if [[ $? -ne 0 ]]; then
  resolve_status="error"
  failed=1
fi

routing_json=$(PAYLOAD_FILE="${payload_file}" ROUTING_KEY="" EXCHANGE="GRANT_EXCHANGE" \
  "${SCRIPT}" --dry-run --json)
routing_status="ok"
EXPECTED_RK="grant.9.test" ROUTING_JSON="${routing_json}" python3 - <<'PY'
import json,os,sys
expected=os.environ["EXPECTED_RK"]
data=json.loads(os.environ["ROUTING_JSON"])
if data.get("routing_key") != expected:
    print("routing_key not derived from grantType", file=sys.stderr)
    sys.exit(1)
PY
if [[ $? -ne 0 ]]; then
  routing_status="error"
  failed=1
fi

strict_status="ok"
if STRICT_GRANT_TYPE=1 ROUTING_KEY="grant.1.contract" PAYLOAD_FILE="${payload_file}" \
  "${SCRIPT}" --dry-run >/dev/null 2>&1; then
  echo "Expected STRICT_GRANT_TYPE mismatch to fail." >&2
  strict_status="error"
  failed=1
fi

details_json=$(PAYLOAD_FILE="${payload_file}" MESSAGE_ID="msg-123" CONTENT_TYPE="application/json" \
  "${SCRIPT}" --dry-run --json)
details_status="ok"
DETAILS_JSON="${details_json}" python3 - <<'PY'
import json,os,sys
req=["status","exchange","routing_key","payload_file","content_type","message_id"]
data=json.loads(os.environ["DETAILS_JSON"])
missing=[key for key in req if key not in data]
if missing:
    print("missing fields: %s" % ", ".join(missing), file=sys.stderr)
    sys.exit(1)
if data.get("status") != "dry_run":
    print("status is not dry_run", file=sys.stderr)
    sys.exit(1)
if not data.get("message_id"):
    print("message_id is empty", file=sys.stderr)
    sys.exit(1)
PY
if [[ $? -ne 0 ]]; then
  details_status="error"
  failed=1
fi

if [[ "${json_output}" -eq 1 ]]; then
  HELP_STATUS="${help_status}" MISSING_PAYLOAD_STATUS="${missing_payload}" \
  MISSING_PAYLOAD_JSON_STATUS="${missing_payload_json_status}" INVALID_JSON_STATUS="${invalid_json_status}" \
  INVALID_JSON_JSON_STATUS="${invalid_json_json_status}" \
  INVALID_EXCHANGE_JSON_STATUS="${invalid_exchange_json_status}" \
  INVALID_ROUTING_JSON_STATUS="${invalid_routing_json_status}" \
  MESSAGE_ID_WS_JSON_STATUS="${message_id_whitespace_json_status}" \
  WHITESPACE_CONTENT_TYPE_JSON_STATUS="${whitespace_content_type_json_status}" \
  LONG_CONTENT_TYPE_JSON_STATUS="${long_content_type_json_status}" \
  LONG_EXCHANGE_JSON_STATUS="${long_exchange_json_status}" \
  LONG_ROUTING_JSON_STATUS="${long_routing_json_status}" \
  LONG_MESSAGE_ID_JSON_STATUS="${long_message_id_json_status}" \
  RESOLVE_STATUS="${resolve_status}" ROUTING_STATUS="${routing_status}" \
  STRICT_STATUS="${strict_status}" DETAILS_STATUS="${details_status}" \
  UNREADABLE_STATUS="${unreadable_payload_status}" \
  UNREADABLE_JSON_STATUS="${unreadable_payload_json_status}" \
  DIRECTORY_STATUS="${directory_payload_status}" \
  DIRECTORY_JSON_STATUS="${directory_payload_json_status}" \
  INVALID_EXCHANGE_STATUS="${invalid_exchange_status}" INVALID_ROUTING_STATUS="${invalid_routing_status}" \
  LONG_CONTENT_TYPE_STATUS="${long_content_type_status}" \
  MESSAGE_ID_WS_STATUS="${message_id_whitespace_status}" EMPTY_MESSAGE_ID_STATUS="${empty_message_id_status}" \
  EMPTY_CONTENT_TYPE_STATUS="${empty_content_type_status}" \
  WHITESPACE_CONTENT_TYPE_STATUS="${whitespace_content_type_status}" \
  LONG_EXCHANGE_STATUS="${long_exchange_status}" LONG_ROUTING_STATUS="${long_routing_status}" \
  LONG_MESSAGE_ID_STATUS="${long_message_id_status}" python3 - <<'PY'
import json,os
status="ok"
for key in ("HELP_STATUS","MISSING_PAYLOAD_STATUS","MISSING_PAYLOAD_JSON_STATUS","INVALID_JSON_STATUS","INVALID_JSON_JSON_STATUS","INVALID_EXCHANGE_JSON_STATUS","INVALID_ROUTING_JSON_STATUS","MESSAGE_ID_WS_JSON_STATUS","WHITESPACE_CONTENT_TYPE_JSON_STATUS","LONG_CONTENT_TYPE_JSON_STATUS","LONG_EXCHANGE_JSON_STATUS","LONG_ROUTING_JSON_STATUS","LONG_MESSAGE_ID_JSON_STATUS","RESOLVE_STATUS","ROUTING_STATUS","STRICT_STATUS","DETAILS_STATUS","UNREADABLE_STATUS","UNREADABLE_JSON_STATUS","DIRECTORY_STATUS","DIRECTORY_JSON_STATUS","INVALID_EXCHANGE_STATUS","INVALID_ROUTING_STATUS","LONG_CONTENT_TYPE_STATUS","MESSAGE_ID_WS_STATUS","EMPTY_MESSAGE_ID_STATUS","EMPTY_CONTENT_TYPE_STATUS","WHITESPACE_CONTENT_TYPE_STATUS","LONG_EXCHANGE_STATUS","LONG_ROUTING_STATUS","LONG_MESSAGE_ID_STATUS"):
    if os.environ.get(key) != "ok":
        status="error"
print(json.dumps({
    "status": status,
    "help": os.environ.get("HELP_STATUS","error"),
    "missing_payload": os.environ.get("MISSING_PAYLOAD_STATUS","error"),
    "missing_payload_json": os.environ.get("MISSING_PAYLOAD_JSON_STATUS","error"),
    "invalid_json_payload": os.environ.get("INVALID_JSON_STATUS","error"),
    "invalid_json_payload_json": os.environ.get("INVALID_JSON_JSON_STATUS","error"),
    "invalid_exchange": os.environ.get("INVALID_EXCHANGE_STATUS","error"),
    "invalid_exchange_json": os.environ.get("INVALID_EXCHANGE_JSON_STATUS","error"),
    "invalid_routing_key": os.environ.get("INVALID_ROUTING_STATUS","error"),
    "invalid_routing_key_json": os.environ.get("INVALID_ROUTING_JSON_STATUS","error"),
    "message_id_whitespace": os.environ.get("MESSAGE_ID_WS_STATUS","error"),
    "message_id_whitespace_json": os.environ.get("MESSAGE_ID_WS_JSON_STATUS","error"),
    "empty_message_id": os.environ.get("EMPTY_MESSAGE_ID_STATUS","error"),
    "empty_content_type": os.environ.get("EMPTY_CONTENT_TYPE_STATUS","error"),
    "whitespace_content_type": os.environ.get("WHITESPACE_CONTENT_TYPE_STATUS","error"),
    "whitespace_content_type_json": os.environ.get("WHITESPACE_CONTENT_TYPE_JSON_STATUS","error"),
    "long_content_type": os.environ.get("LONG_CONTENT_TYPE_STATUS","error"),
    "long_content_type_json": os.environ.get("LONG_CONTENT_TYPE_JSON_STATUS","error"),
    "long_exchange": os.environ.get("LONG_EXCHANGE_STATUS","error"),
    "long_exchange_json": os.environ.get("LONG_EXCHANGE_JSON_STATUS","error"),
    "long_routing_key": os.environ.get("LONG_ROUTING_STATUS","error"),
    "long_routing_key_json": os.environ.get("LONG_ROUTING_JSON_STATUS","error"),
    "long_message_id": os.environ.get("LONG_MESSAGE_ID_STATUS","error"),
    "long_message_id_json": os.environ.get("LONG_MESSAGE_ID_JSON_STATUS","error"),
    "unreadable_payload": os.environ.get("UNREADABLE_STATUS","error"),
    "unreadable_payload_json": os.environ.get("UNREADABLE_JSON_STATUS","error"),
    "directory_payload": os.environ.get("DIRECTORY_STATUS","error"),
    "directory_payload_json": os.environ.get("DIRECTORY_JSON_STATUS","error"),
    "resolve_payload": os.environ.get("RESOLVE_STATUS","error"),
    "routing_key": os.environ.get("ROUTING_STATUS","error"),
    "strict_grant_type": os.environ.get("STRICT_STATUS","error"),
    "details": os.environ.get("DETAILS_STATUS","error"),
}))
PY
  exit "${failed}"
fi

if [[ "${failed}" -ne 0 ]]; then
  exit 1
fi
if [[ "${json_output}" -eq 0 ]]; then
  echo "[ok] publish_test_message dry-run tests passed"
fi
