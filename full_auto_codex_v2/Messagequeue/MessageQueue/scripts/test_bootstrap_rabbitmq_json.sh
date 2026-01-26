#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/bootstrap_rabbitmq.sh"

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

cat > "${stub_dir}/scripts/check_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/check_rabbitmq.sh"

cat > "${stub_dir}/bin/curl" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/bin/curl"

output=$(PATH="${stub_dir}/bin:$PATH" ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") in ("ok","error"); assert "host" in data and "port" in data'; then
  echo "bootstrap_rabbitmq JSON output missing fields." >&2
  exit 1
fi

echo "[ok] bootstrap_rabbitmq json tests passed"
