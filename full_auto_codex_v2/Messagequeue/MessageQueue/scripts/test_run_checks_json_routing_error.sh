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

mkdir -p "${stub_root}/scripts"
cat > "${stub_root}/scripts/doctor.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "${stub_root}/scripts/test_routing_matrix.sh" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB
chmod +x "${stub_root}/scripts"/*.sh

set +e
output=$(ROOT_OVERRIDE="${stub_root}" "${SCRIPT}" --json 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit on routing error" >&2
  exit 1
fi
if ! echo "${output}" | rg -q '"routing_matrix": "error"'; then
  echo "Expected routing_matrix error in JSON" >&2
  exit 1
fi

echo "[ok] run_checks json routing error tests passed"
