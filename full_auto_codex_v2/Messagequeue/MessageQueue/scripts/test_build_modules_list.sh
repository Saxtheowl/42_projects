#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/build_modules.sh"

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
exit 99
STUB
chmod +x "${stub_dir}/mvn"

list_output=$(PATH="${stub_dir}:$PATH" "${SCRIPT}" --list)
if [[ -z "${list_output}" ]]; then
  echo "Expected module list output." >&2
  exit 1
fi
if ! printf '%s' "${list_output}" | rg -q "services/producer"; then
  echo "Expected services/producer in module list." >&2
  exit 1
fi

if printf '%s' "${list_output}" | rg -q "grant_other_documents"; then
  :
else
  echo "Expected consumers modules in module list." >&2
  exit 1
fi

echo "[ok] build_modules list tests passed"
