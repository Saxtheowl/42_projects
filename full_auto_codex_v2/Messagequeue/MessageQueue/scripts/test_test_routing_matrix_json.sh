#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/test_routing_matrix.sh"

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

cat > "${stub_dir}/scripts/validate_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/validate_rabbitmq.sh"

cat > "${stub_dir}/scripts/publish_test_message.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/publish_test_message.sh"

cat > "${stub_dir}/bin/curl" <<'STUB'
#!/usr/bin/env bash
set -euo pipefail
if [[ "${*}" == *"/api/queues/"* ]]; then
  printf '%s\n' '{"messages":0}'
  exit 0
fi
exit 0
STUB
chmod +x "${stub_dir}/bin/curl"

output=$(PATH="${stub_dir}/bin:$PATH" ROOT_OVERRIDE="${stub_dir}" \
  CONTRACTS_ROUTING_KEY="no.match" OTHER_ROUTING_KEY="no.match" \
  ROUTING_KEYS="foo.bar,baz.qux" "${SCRIPT}" --json)

if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "ok"; assert data.get("expected",{}).get("grant_contracts") == 0; assert data.get("actual",{}).get("grant_contracts") == 0'; then
  echo "Routing matrix JSON output unexpected." >&2
  exit 1
fi

echo "[ok] test_routing_matrix json tests passed"
