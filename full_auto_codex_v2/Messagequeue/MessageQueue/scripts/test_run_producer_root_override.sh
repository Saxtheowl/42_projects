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

mkdir -p "${stub_dir}/services/producer"

stub_bin=$(mktemp -d)
cleanup_bin() {
  rm -rf "${stub_bin}"
}
trap cleanup_bin EXIT

cat > "${stub_bin}/mvn" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${stub_bin}/mvn"

PATH="${stub_bin}:$PATH" ROOT_OVERRIDE="${stub_dir}" "${SCRIPT}"

echo "[ok] run_producer ROOT_OVERRIDE tests passed"
