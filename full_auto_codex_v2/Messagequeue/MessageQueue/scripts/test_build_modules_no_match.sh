#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cat <<'SH' > "${TMP_DIR}/mvn"
#!/usr/bin/env bash
echo "mvn stub: $*"
SH
chmod +x "${TMP_DIR}/mvn"

export PATH="${TMP_DIR}:${PATH}"

set +e
output="$(MODULES="does_not_exist" "${ROOT_DIR}/scripts/build_modules.sh" 2>&1)"
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit for unknown MODULES" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "No modules matched"; then
  echo "Expected no modules matched error" >&2
  exit 1
fi

echo "[ok] build_modules no match tests passed"
