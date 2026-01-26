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
echo "mvn stub" >&2
exit 0
STUB
chmod +x "${stub_dir}/mvn"

set +e
output=$(ROOT_OVERRIDE="${stub_dir}" MODULES="food_application" PATH="${stub_dir}:$PATH" "${SCRIPT}" 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit when consumer dir missing" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "No such file|cannot"; then
  echo "Expected missing directory error" >&2
  exit 1
fi

echo "[ok] test_consumers missing dir tests passed"
