#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/run_local_flow.sh"

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
cat > "${stub_root}/scripts/setup_env.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "${stub_root}/scripts/load_env.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "${stub_root}/scripts/check_prereqs.sh" <<'STUB'
#!/usr/bin/env bash
echo '{"status":"ok"}'
exit 0
STUB
cat > "${stub_root}/scripts/smoke_local.sh" <<'STUB'
#!/usr/bin/env bash
echo '{"status":"error","step":"smoke"}'
exit 1
STUB
cat > "${stub_root}/scripts/status_report.sh" <<'STUB'
#!/usr/bin/env bash
echo "status_report should not run" >&2
exit 1
STUB
chmod +x "${stub_root}/scripts"/*.sh

set +e
output=$(ROOT_OVERRIDE="${stub_root}" "${SCRIPT}" --json 2>&1)
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit on smoke failure" >&2
  exit 1
fi
if ! echo "${output}" | rg -q '"status":"error"'; then
  echo "Expected JSON error output" >&2
  exit 1
fi
if echo "${output}" | rg -q "status_report should not run"; then
  echo "Unexpected status_report execution" >&2
  exit 1
fi

echo "[ok] run_local_flow json smoke failure tests passed"
