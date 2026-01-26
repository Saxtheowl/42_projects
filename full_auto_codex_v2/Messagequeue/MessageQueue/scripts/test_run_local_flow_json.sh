#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_local_flow.sh"

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

for script in setup_env.sh load_env.sh check_prereqs.sh smoke_local.sh status_report.sh; do
  cat > "${stub_dir}/scripts/${script}" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
  chmod +x "${stub_dir}/scripts/${script}"
done

output=$(ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json)
if [[ -n "${output}" ]]; then
  if ! printf '%s' "${output}" | python3 -c 'import json,sys; json.loads(sys.stdin.read().strip())'; then
    echo "Unexpected JSON output." >&2
    exit 1
  fi
fi

echo "[ok] run_local_flow json tests passed"
