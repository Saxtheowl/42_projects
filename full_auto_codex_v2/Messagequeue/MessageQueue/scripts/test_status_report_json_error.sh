#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/status_report.sh"

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

cat > "${stub_dir}/scripts/check_prereqs.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/check_prereqs.sh"

cat > "${stub_dir}/scripts/check_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB
chmod +x "${stub_dir}/scripts/check_rabbitmq.sh"

output=$(ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json || true)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "error"; assert "management" in data.get("error","")'; then
  echo "status_report JSON error output unexpected." >&2
  exit 1
fi

echo "[ok] status_report json error tests passed"
