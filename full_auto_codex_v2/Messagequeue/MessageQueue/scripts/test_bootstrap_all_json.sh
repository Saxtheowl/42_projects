#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/bootstrap_all.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

mkdir -p "${stub_dir}/scripts" "${stub_dir}/bin"

cat > "${stub_dir}/bin/docker" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/bin/docker"

cat > "${stub_dir}/scripts/wait_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/wait_rabbitmq.sh"

cat > "${stub_dir}/scripts/bootstrap_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/bootstrap_rabbitmq.sh"

cat > "${stub_dir}/scripts/validate_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/validate_rabbitmq.sh"

cat > "${stub_dir}/scripts/test_routing.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/test_routing.sh"

output=$(PATH="${stub_dir}/bin:$PATH" ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json --silent)
if [[ -n "${output}" ]]; then
  if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") in ("ok","error")'; then
    echo "Unexpected JSON output." >&2
    exit 1
  fi
fi

echo "[ok] bootstrap_all json tests passed"
