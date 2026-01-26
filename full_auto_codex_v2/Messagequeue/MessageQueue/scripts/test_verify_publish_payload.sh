#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/verify_publish_payload.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

invalid_payload=$(mktemp)
cleanup() {
  rm -f "${invalid_payload}"
}
trap cleanup EXIT

# Valid default payload should succeed.
if ! "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected verify_publish_payload to succeed with default payload." >&2
  exit 1
fi

# JSON mode should emit JSON.
json_output=$("${SCRIPT}" "${ROOT_DIR}/docs/sample_publish_payload.json" "${ROOT_DIR}/docs" --json)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; json.loads(sys.stdin.read().strip())'; then
  echo "Expected JSON output from verify_publish_payload --json." >&2
  exit 1
fi

# Invalid payload should fail.
printf '%s\n' '{bad json' > "${invalid_payload}"
if "${SCRIPT}" "${invalid_payload}" "${ROOT_DIR}/docs" >/dev/null 2>&1; then
  echo "Expected verify_publish_payload to fail with invalid payload." >&2
  exit 1
fi

echo "[ok] verify_publish_payload tests passed"
