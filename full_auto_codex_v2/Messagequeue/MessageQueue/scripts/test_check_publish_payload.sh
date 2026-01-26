#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/check_publish_payload.py"

if [[ ! -f "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

work_dir=$(mktemp -d)
cleanup() {
  rm -rf "${work_dir}"
}
trap cleanup EXIT

valid_payload="${work_dir}/valid.json"
invalid_payload="${work_dir}/invalid.json"
long_message="${work_dir}/long.json"

cat > "${valid_payload}" <<'JSON'
{
  "exchange": "grant",
  "routing_key": "grant.student",
  "doc_type": "financial",
  "content_type": "application/pdf",
  "message_id": "MSG-1234"
}
JSON

cat > "${invalid_payload}" <<'JSON'
{
  "exchange": "grant",
  "routing_key": "bad key",
  "doc_type": "financial",
  "content_type": " ",
  "message_id": "MSG 1"
}
JSON

cat > "${long_message}" <<'JSON'
{
  "exchange": "grant",
  "routing_key": "grant.student",
  "doc_type": "financial",
  "content_type": "application/pdf",
  "message_id": "MSG-0123456789012345678901234567890123456789012345678901234567890123"
}
JSON

if ! python3 "${SCRIPT}" --payload "${valid_payload}" --directory "${work_dir}" >/dev/null 2>&1; then
  echo "Expected valid payload to pass." >&2
  exit 1
fi

if python3 "${SCRIPT}" --payload "${invalid_payload}" --directory "${work_dir}" >/dev/null 2>&1; then
  echo "Expected invalid payload to fail." >&2
  exit 1
fi

if python3 "${SCRIPT}" --payload "${long_message}" --directory "${work_dir}" >/dev/null 2>&1; then
  echo "Expected long message_id payload to fail." >&2
  exit 1
fi

json_output=$(python3 "${SCRIPT}" --payload "${valid_payload}" --directory "${work_dir}" --json)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="ok"'; then
  echo "Expected JSON status ok for valid payload." >&2
  exit 1
fi

echo "[ok] check_publish_payload tests passed"
