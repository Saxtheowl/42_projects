#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/tail_rabbitmq_logs.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "SERVICE"; then
  echo "Expected --help to mention SERVICE." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "FOLLOW"; then
  echo "Expected --help to mention FOLLOW." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "TAIL"; then
  echo "Expected --help to mention TAIL." >&2
  exit 1
fi

echo "[ok] tail_rabbitmq_logs help tests passed"
