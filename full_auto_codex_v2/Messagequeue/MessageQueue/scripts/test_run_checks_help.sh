#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_checks.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

help_output=$("${SCRIPT}" --help)
if ! printf '%s' "${help_output}" | rg -q -- "--skip-doctor"; then
  echo "Expected --help to mention --skip-doctor." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "--skip-routing"; then
  echo "Expected --help to mention --skip-routing." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "--silent"; then
  echo "Expected --help to mention --silent." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "--json"; then
  echo "Expected --help to mention --json." >&2
  exit 1
fi
if ! printf '%s' "${help_output}" | rg -q -- "ROOT_OVERRIDE"; then
  echo "Expected --help to mention ROOT_OVERRIDE." >&2
  exit 1
fi

echo "[ok] run_checks help tests passed"
