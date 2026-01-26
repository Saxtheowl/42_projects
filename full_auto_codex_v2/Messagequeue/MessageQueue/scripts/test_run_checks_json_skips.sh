#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_checks.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

mkdir -p "${stub_dir}/scripts"

cat > "${stub_dir}/scripts/doctor.sh" <<'STUB'
#!/usr/bin/env bash
exit 99
STUB
chmod +x "${stub_dir}/scripts/doctor.sh"

cat > "${stub_dir}/scripts/test_routing_matrix.sh" <<'STUB'
#!/usr/bin/env bash
exit 99
STUB
chmod +x "${stub_dir}/scripts/test_routing_matrix.sh"

output=$(ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json --skip-doctor --skip-routing)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "ok"; assert data.get("doctor") == "skipped"; assert data.get("routing_matrix") == "skipped"'; then
  echo "run_checks JSON output unexpected with skips." >&2
  exit 1
fi

echo "[ok] run_checks json skip tests passed"
