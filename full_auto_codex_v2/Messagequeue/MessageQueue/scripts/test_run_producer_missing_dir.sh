#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/run_producer.sh"

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

ROOT_OVERRIDE=$(mktemp -d)
cleanup_root() {
  rm -rf "${ROOT_OVERRIDE}"
}
trap cleanup_root EXIT

output=$(PATH="${stub_dir}:$PATH" ROOT_OVERRIDE="${ROOT_OVERRIDE}" "${SCRIPT}" 2>&1 || true)
if [[ "${output}" != *"No such file"* && "${output}" != *"cannot"* ]]; then
  echo "Expected missing producer directory error." >&2
  exit 1
fi

echo "[ok] run_producer missing dir tests passed"
