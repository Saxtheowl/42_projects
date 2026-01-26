#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/list_exchanges.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

# Stub curl to avoid network calls.
stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

cat > "${stub_dir}/curl" <<'STUB'
#!/usr/bin/env bash
cat <<'JSON'
[
  {"name":"ex1"},
  {"name":"ex2"}
]
JSON
exit 0
STUB
chmod +x "${stub_dir}/curl"

json_output=$(PATH="${stub_dir}:$PATH" EXCHANGES="ex2" "${SCRIPT}" --json)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data==[{"name":"ex2","type":""}]'; then
  echo "Expected list_exchanges --json to return filtered exchange list." >&2
  exit 1
fi

echo "[ok] list_exchanges json tests passed"
