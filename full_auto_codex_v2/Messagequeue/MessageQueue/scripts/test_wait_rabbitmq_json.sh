#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/wait_rabbitmq.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

json_output=$(TIMEOUT=0 "${SCRIPT}" --json 2>/dev/null || true)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="error"; assert data.get("timeout")==0'; then
  echo "Expected wait_rabbitmq --json to return error with timeout=0." >&2
  exit 1
fi

echo "[ok] wait_rabbitmq json tests passed"
