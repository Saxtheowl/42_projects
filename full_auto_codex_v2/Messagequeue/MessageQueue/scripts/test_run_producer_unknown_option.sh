#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_producer.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

output=$("${SCRIPT}" --nope 2>&1 || true)
if [[ "${output}" != *"Unknown option"* ]]; then
  echo "Expected unknown option error." >&2
  exit 1
fi

echo "[ok] run_producer unknown option tests passed"
