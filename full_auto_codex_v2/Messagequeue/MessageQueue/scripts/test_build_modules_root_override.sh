#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

mkdir -p "${TMP_DIR}/services/producer"

cat <<'SH' > "${TMP_DIR}/mvn"
#!/usr/bin/env bash
echo "cwd:${PWD}"
SH
chmod +x "${TMP_DIR}/mvn"

export PATH="${TMP_DIR}:${PATH}"

output="$(ROOT_OVERRIDE="${TMP_DIR}" MODULES="producer" "${ROOT_DIR}/scripts/build_modules.sh" 2>&1)"
if ! echo "${output}" | grep -q "Building services/producer"; then
  echo "Expected build line" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "cwd:${TMP_DIR}/services/producer"; then
  echo "Expected mvn to run in ROOT_OVERRIDE" >&2
  exit 1
fi

echo "[ok] build_modules ROOT_OVERRIDE tests passed"
