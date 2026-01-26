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
chmod +x "${stub_root}/scripts"/*.sh

output=$(ROOT_OVERRIDE="${stub_root}" "${SCRIPT}" --json --skip-routing 2>&1)
if ! echo "${output}" | rg -q '"doctor": "ok"'; then
  echo "Expected doctor ok in JSON" >&2
  exit 1
fi
if ! echo "${output}" | rg -q '"routing_matrix": "skipped"'; then
  echo "Expected routing_matrix skipped in JSON" >&2
  exit 1
fi

echo "[ok] run_checks json skip routing doctor ok tests passed"
