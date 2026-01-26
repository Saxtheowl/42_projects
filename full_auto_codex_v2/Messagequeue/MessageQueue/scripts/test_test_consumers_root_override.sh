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
echo "cwd:${PWD}"
STUB
chmod +x "${stub_dir}/mvn"

mkdir -p "${stub_dir}/services/consumers/food_application"

output=$(ROOT_OVERRIDE="${stub_dir}" MODULES="food_application" PATH="${stub_dir}:$PATH" "${SCRIPT}" 2>&1)
if ! echo "${output}" | rg -q "Testing services/consumers/food_application"; then
  echo "Expected testing line" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "cwd:${stub_dir}/services/consumers/food_application"; then
  echo "Expected mvn cwd in ROOT_OVERRIDE" >&2
  exit 1
fi

echo "[ok] test_consumers ROOT_OVERRIDE tests passed"
