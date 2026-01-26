#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/check_rabbitmq.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

json_output=$(RABBITMQ_PORT=1 "${SCRIPT}" --json 2>/dev/null || true)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="error"; assert data.get("port")==1'; then
  echo "Expected check_rabbitmq --json to return error for bad port." >&2
  exit 1
fi

echo "[ok] check_rabbitmq json tests passed"
