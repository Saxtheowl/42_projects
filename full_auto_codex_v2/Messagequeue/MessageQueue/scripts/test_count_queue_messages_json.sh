#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/count_queue_messages.sh"

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
  {"name":"q1","messages":1},
  {"name":"q2","messages":2}
]
JSON
exit 0
STUB
chmod +x "${stub_dir}/curl"

json_output=$(PATH="${stub_dir}:$PATH" QUEUES="q2" "${SCRIPT}" --json)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data==[{"name":"q2","messages":2}]'; then
  echo "Expected count_queue_messages --json to return filtered count." >&2
  exit 1
fi

echo "[ok] count_queue_messages json tests passed"
