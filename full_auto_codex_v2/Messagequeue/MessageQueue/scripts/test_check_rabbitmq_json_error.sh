#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/check_rabbitmq.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

cat > "${stub_dir}/curl" <<'STUB'
#!/usr/bin/env bash
exit 7
STUB
chmod +x "${stub_dir}/curl"

output=$(PATH="${stub_dir}:$PATH" "${SCRIPT}" --json 2>/dev/null || true)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "error"; assert "host" in data and "port" in data'; then
  echo "check_rabbitmq JSON error output unexpected." >&2
  exit 1
fi

echo "[ok] check_rabbitmq json error tests passed"
