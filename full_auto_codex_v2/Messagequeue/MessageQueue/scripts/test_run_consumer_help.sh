#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_consumer.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "--list"; then
  echo "Expected --help to mention --list." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "grant_other_documents"; then
  echo "Expected --help to mention example consumers." >&2
  exit 1
fi

echo "[ok] run_consumer help tests passed"
