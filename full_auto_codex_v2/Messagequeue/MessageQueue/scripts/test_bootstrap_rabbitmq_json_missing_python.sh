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

mkdir -p "${stub_dir}/bin"

cat > "${stub_dir}/bin/curl" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/bin/curl"

cat > "${stub_dir}/bin/python3" <<'STUB'
#!/usr/bin/env bash
exit 127
STUB
chmod +x "${stub_dir}/bin/python3"

output=$(PATH="${stub_dir}/bin:$PATH" "${SCRIPT}" --json 2>/dev/null || true)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "error"; assert data.get("step") == "bootstrap"'; then
  echo "bootstrap_rabbitmq JSON output unexpected when python3 missing." >&2
  exit 1
fi

echo "[ok] bootstrap_rabbitmq json missing python tests passed"
