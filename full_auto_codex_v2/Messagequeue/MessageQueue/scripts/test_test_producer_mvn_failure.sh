#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/test_producer.sh"

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
echo "mvn stub failing" >&2
exit 2
STUB
chmod +x "${stub_dir}/mvn"

mkdir -p "${stub_dir}/services/producer"

set +e
output=$(ROOT_OVERRIDE="${stub_dir}" PATH="${stub_dir}:$PATH" "${SCRIPT}" 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit when mvn fails" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "mvn stub failing"; then
  echo "Expected mvn failure output" >&2
  exit 1
fi

echo "[ok] test_producer mvn failure tests passed"
