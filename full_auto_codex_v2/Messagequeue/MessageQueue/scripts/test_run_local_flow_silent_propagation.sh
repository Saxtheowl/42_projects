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
if [[ "${1:-}" != "--silent" ]]; then
  echo "expected --silent" >&2
  exit 1
fi
echo "check_prereqs silent ok"
exit 0
STUB
cat > "${stub_root}/scripts/smoke_local.sh" <<'STUB'
#!/usr/bin/env bash
if [[ "${1:-}" != "--silent" ]]; then
  echo "expected --silent" >&2
  exit 1
fi
echo "smoke_local silent ok"
exit 0
STUB
cat > "${stub_root}/scripts/status_report.sh" <<'STUB'
#!/usr/bin/env bash
if [[ "${1:-}" != "--silent" ]]; then
  echo "expected --silent" >&2
  exit 1
fi
echo "status_report silent ok"
exit 0
STUB
chmod +x "${stub_root}/scripts"/*.sh

output=$(ROOT_OVERRIDE="${stub_root}" "${SCRIPT}" --silent 2>&1)
if ! echo "${output}" | rg -q "check_prereqs silent ok"; then
  echo "Expected check_prereqs silent output" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "smoke_local silent ok"; then
  echo "Expected smoke_local silent output" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "status_report silent ok"; then
  echo "Expected status_report silent output" >&2
  exit 1
fi

echo "[ok] run_local_flow silent propagation tests passed"
