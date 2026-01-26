#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/load_env.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

work_dir=$(mktemp -d)
cleanup() {
  rm -rf "${work_dir}"
}
trap cleanup EXIT

missing_env="${work_dir}/missing.env"
if ENV_FILE="${missing_env}" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected load_env to fail for missing env file." >&2
  exit 1
fi

env_file="${work_dir}/test.env"
cat > "${env_file}" <<'ENV'
RABBITMQ_HOST=localhost
RABBITMQ_PORT=5672
EXCHANGE=grant
PAYLOAD_FILE=docs/sample_student.json
PDF_OUTPUT_DIR=/tmp/mq-pdfs
ENV

output=$(ENV_FILE="${env_file}" "${SCRIPT}")
if ! printf '%s' "${output}" | rg -q "Loaded env"; then
  echo "Expected load_env to print loaded message." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[set\] RABBITMQ_HOST"; then
  echo "Expected RABBITMQ_HOST to be set." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[set\] EXCHANGE"; then
  echo "Expected EXCHANGE to be set." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[set\] PDF_OUTPUT_DIR"; then
  echo "Expected PDF_OUTPUT_DIR to be set." >&2
  exit 1
fi
if ! printf '%s' "${output}" | rg -q "\[unset\] RABBITMQ_USER"; then
  echo "Expected RABBITMQ_USER to be unset in test env." >&2
  exit 1
fi

echo "[ok] load_env tests passed"
