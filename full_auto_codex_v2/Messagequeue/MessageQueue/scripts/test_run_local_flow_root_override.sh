#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT_DIR}/scripts/run_local_flow.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
scripts_dir="${stub_dir}/scripts"
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

mkdir -p "${scripts_dir}"

cat > "${scripts_dir}/check_prereqs.sh" <<'STUB'
#!/usr/bin/env bash
echo "check_prereqs stub"
exit 0
STUB
cat > "${scripts_dir}/setup_env.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "${scripts_dir}/load_env.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
cat > "${scripts_dir}/smoke_local.sh" <<'STUB'
#!/usr/bin/env bash
echo "smoke_local stub"
exit 0
STUB
cat > "${scripts_dir}/status_report.sh" <<'STUB'
#!/usr/bin/env bash
echo "status_report stub"
exit 0
STUB
chmod +x "${scripts_dir}"/*.sh

output=$(ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --silent 2>&1)
if ! echo "${output}" | rg -q "check_prereqs stub"; then
  echo "Expected check_prereqs stub output" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "smoke_local stub"; then
  echo "Expected smoke_local stub output" >&2
  exit 1
fi
if ! echo "${output}" | rg -q "status_report stub"; then
  echo "Expected status_report stub output" >&2
  exit 1
fi

echo "[ok] run_local_flow ROOT_OVERRIDE tests passed"
