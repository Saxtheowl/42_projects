#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/tail_rabbitmq_logs.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

cat > "${stub_dir}/docker" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/docker"

output=$(PATH="${stub_dir}:$PATH" "${SCRIPT}" --json 2>&1 || true)
if [[ "${output}" != *"Unknown option"* ]]; then
  echo "Expected unknown option error for --json." >&2
  exit 1
fi

echo "[ok] tail_rabbitmq_logs json unsupported tests passed"
