#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/run_checks.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_root=$(mktemp -d)
cleanup() {
  rm -rf "${stub_root}"
}
trap cleanup EXIT

set +e
output=$(ROOT_OVERRIDE="${stub_root}" "${SCRIPT}" --silent 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit when scripts missing" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "No such file|cannot"; then
  echo "Expected missing script error" >&2
  exit 1
fi

echo "[ok] run_checks missing scripts with ROOT_OVERRIDE tests passed"
