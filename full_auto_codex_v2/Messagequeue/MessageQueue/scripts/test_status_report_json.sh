#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/status_report.sh"

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

cat > "${stub_dir}/scripts/check_prereqs.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/check_prereqs.sh"

cat > "${stub_dir}/scripts/check_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/check_rabbitmq.sh"

cat > "${stub_dir}/scripts/count_queue_messages.sh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' '[{"queue":"q1","messages":0}]'
STUB
chmod +x "${stub_dir}/scripts/count_queue_messages.sh"

cat > "${stub_dir}/scripts/list_exchanges.sh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' '[{"name":"ex1","type":"fanout"}]'
STUB
chmod +x "${stub_dir}/scripts/list_exchanges.sh"

cat > "${stub_dir}/scripts/list_bindings.sh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' '[{"source":"ex1","destination":"q1","routing_key":""}]'
STUB
chmod +x "${stub_dir}/scripts/list_bindings.sh"

output=$(ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "ok"; assert data.get("queues") and data.get("exchanges") and data.get("bindings")'; then
  echo "status_report JSON output unexpected." >&2
  exit 1
fi

echo "[ok] status_report json tests passed"
