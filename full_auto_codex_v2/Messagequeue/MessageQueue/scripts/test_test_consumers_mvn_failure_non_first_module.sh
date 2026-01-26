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

cat > "${stub_dir}/mvn" <<'STUB'
#!/usr/bin/env bash
if [[ "${PWD}" == *"financial_assistance" ]]; then
  echo "mvn stub failing on financial_assistance" >&2
  exit 3
fi
exit 0
STUB
chmod +x "${stub_dir}/mvn"

mkdir -p "${stub_dir}/services/consumers/food_application"
mkdir -p "${stub_dir}/services/consumers/financial_assistance"

set +e
output=$(ROOT_OVERRIDE="${stub_dir}" MODULES="food_application,financial_assistance" PATH="${stub_dir}:$PATH" "${SCRIPT}" 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit when mvn fails on second module" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "Testing services/consumers/food_application"; then
  echo "Expected food_application testing line" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "Testing services/consumers/financial_assistance"; then
  echo "Expected financial_assistance testing line" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "mvn stub failing on financial_assistance"; then
  echo "Expected mvn failure output" >&2
  exit 1
fi

echo "[ok] test_consumers mvn failure mid-run tests passed"
