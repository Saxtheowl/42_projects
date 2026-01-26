#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/smoke_local.sh"

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

for script in wait_rabbitmq.sh check_rabbitmq.sh bootstrap_rabbitmq.sh validate_rabbitmq.sh test_routing.sh publish_test_message.sh count_queue_messages.sh consume_test_message.sh; do
  cat > "${stub_dir}/scripts/${script}" <<'STUB'
#!/usr/bin/env bash
if [[ "$0" == *"count_queue_messages.sh"* ]]; then
  printf '%s\n' '[]'
  exit 0
fi
exit 0
STUB
  chmod +x "${stub_dir}/scripts/${script}"
done

output=$(PATH="${stub_dir}/bin:$PATH" ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json)
if [[ -n "${output}" ]]; then
  if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") in ("ok","error")'; then
    echo "Unexpected JSON output." >&2
    exit 1
  fi
fi

echo "[ok] smoke_local json tests passed"
