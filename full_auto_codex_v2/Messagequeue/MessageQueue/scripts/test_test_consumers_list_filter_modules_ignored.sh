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
exit 99
STUB
chmod +x "${stub_dir}/mvn"

set +e
output=$(MODULES="does_not_exist" PATH="${stub_dir}:$PATH" "${SCRIPT}" --list 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit for MODULES mismatch" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "No modules matched"; then
  echo "Expected no modules matched error" >&2
  exit 1
fi

echo "[ok] test_consumers list MODULES mismatch tests passed"
