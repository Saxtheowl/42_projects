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
printf '%s\n' '[{"queue":"q1","messages":1}]'
STUB
chmod +x "${stub_dir}/scripts/count_queue_messages.sh"

cat > "${stub_dir}/scripts/list_exchanges.sh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' '[{"name":"ex1","type":"fanout"}]'
STUB
chmod +x "${stub_dir}/scripts/list_exchanges.sh"

cat > "${stub_dir}/scripts/list_bindings.sh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' '[{"source":"ex1","destination":"q1","routing_key":"rk"}]'
STUB
chmod +x "${stub_dir}/scripts/list_bindings.sh"

output=$(ROOT_OVERRIDE="${stub_dir}" QUEUE_FILTER="q1" EXCHANGE_FILTER="ex1" SOURCE_FILTER="ex1" DESTINATION_FILTER="q1" ROUTING_KEY_FILTER="rk" "${SCRIPT}" --json)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); f=data.get("filters",{}); assert f.get("queue_filter")=="q1"; assert f.get("exchange_filter")=="ex1"; assert f.get("source_filter")=="ex1"; assert f.get("destination_filter")=="q1"; assert f.get("routing_key_filter")=="rk"'; then
  echo "status_report JSON filters output unexpected." >&2
  exit 1
fi

echo "[ok] status_report json filters tests passed"
