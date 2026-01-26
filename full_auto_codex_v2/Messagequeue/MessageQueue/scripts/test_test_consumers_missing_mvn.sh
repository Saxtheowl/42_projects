#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/test_consumers.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

set +e
output=$(PATH="${stub_dir}:$PATH" "${SCRIPT}" 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit when mvn is missing" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "mvn is required"; then
  echo "Expected mvn required message" >&2
  exit 1
fi

echo "[ok] test_consumers missing mvn tests passed"
