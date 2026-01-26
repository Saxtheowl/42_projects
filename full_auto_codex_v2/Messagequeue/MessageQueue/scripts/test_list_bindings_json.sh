#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/list_bindings.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

# Use a minimal stub to avoid network calls.
stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

cat > "${stub_dir}/curl" <<'STUB'
#!/usr/bin/env bash
cat <<'JSON'
[
  {"source":"ex","destination":"q","routing_key":"rk"}
]
JSON
exit 0
STUB
chmod +x "${stub_dir}/curl"

json_output=$(PATH="${stub_dir}:$PATH" SOURCES="ex" DESTINATIONS="q" ROUTING_KEYS="rk" "${SCRIPT}" --json)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data==[{"source":"ex","destination":"q","routing_key":"rk"}]'; then
  echo "Expected list_bindings --json to return filtered binding." >&2
  exit 1
fi

echo "[ok] list_bindings json tests passed"
