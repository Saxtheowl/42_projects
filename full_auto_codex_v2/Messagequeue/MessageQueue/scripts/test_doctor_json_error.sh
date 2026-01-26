#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/doctor.sh"

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
printf '%s\n' '{"status":"error","missing":["docker"]}'
STUB
chmod +x "${stub_dir}/scripts/check_prereqs.sh"

cat > "${stub_dir}/scripts/check_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' '{"status":"ok"}'
STUB
chmod +x "${stub_dir}/scripts/check_rabbitmq.sh"

cat > "${stub_dir}/scripts/validate_rabbitmq.sh" <<'STUB'
#!/usr/bin/env bash
printf '%s\n' '{"status":"ok"}'
STUB
chmod +x "${stub_dir}/scripts/validate_rabbitmq.sh"

cat > "${stub_dir}/scripts/validate_payload.py" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/validate_payload.py"

cat > "${stub_dir}/scripts/test_validate_payload.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/test_validate_payload.sh"

cat > "${stub_dir}/scripts/test_publish_test_message.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/scripts/test_publish_test_message.sh"

output=$(ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}" --json || true)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "error"; assert data.get("prereqs") == "error"'; then
  echo "Doctor JSON error output unexpected." >&2
  exit 1
fi

echo "[ok] doctor json error tests passed"
