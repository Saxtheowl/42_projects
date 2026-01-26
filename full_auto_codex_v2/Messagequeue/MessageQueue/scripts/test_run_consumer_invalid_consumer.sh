#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_consumer.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

cat > "${stub_dir}/mvn" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_dir}/mvn"

output=$(PATH="${stub_dir}:$PATH" "${SCRIPT}" nonexistent_consumer 2>&1 || true)
if [[ "${output}" != *"No such file"* && "${output}" != *"cannot"* ]]; then
  echo "Expected failure for invalid consumer." >&2
  exit 1
fi

echo "[ok] run_consumer invalid consumer tests passed"
