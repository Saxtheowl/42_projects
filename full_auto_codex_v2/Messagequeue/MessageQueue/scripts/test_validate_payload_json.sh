#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/validate_payload.py"

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

cat > "${valid_payload}" <<'JSON'
{
  "studentId": "ST-1",
  "firstName": "Ada",
  "lastName": "Lovelace",
  "email": "ada@example.test",
  "grantType": "grant.1.contract"
}
JSON

cat > "${invalid_payload}" <<'JSON'
{
  "studentId": 123,
  "firstName": "Ada",
  "lastName": "Lovelace",
  "email": "ada@example.test",
  "grantType": "grant"
}
JSON

json_ok=$(PAYLOAD_FILE="${valid_payload}" python3 "${SCRIPT}" --json)
if ! printf '%s' "${json_ok}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="ok"'; then
  echo "Expected validate_payload --json to return status ok for valid payload." >&2
  exit 1
fi

json_fail=$(PAYLOAD_FILE="${invalid_payload}" python3 "${SCRIPT}" --json 2>/dev/null || true)
if ! printf '%s' "${json_fail}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="error"; assert data.get("errors")'; then
  echo "Expected validate_payload --json to return errors for invalid payload." >&2
  exit 1
fi

echo "[ok] validate_payload json tests passed"
