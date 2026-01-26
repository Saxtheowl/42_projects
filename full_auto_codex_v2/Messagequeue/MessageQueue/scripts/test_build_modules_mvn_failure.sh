#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

cat <<'SH' > "${TMP_DIR}/mvn"
#!/usr/bin/env bash
if [[ "${1:-}" == "-q" ]]; then
  echo "mvn stub failing" >&2
  exit 2
fi
exit 0
SH
chmod +x "${TMP_DIR}/mvn"

export PATH="${TMP_DIR}:${PATH}"

set +e
output="$(MODULES="producer" "${ROOT_DIR}/scripts/build_modules.sh" 2>&1)"
status=$?
set -e

if [ "${status}" -eq 0 ]; then
  echo "Expected non-zero exit when mvn fails" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "Building services/producer"; then
  echo "Expected build start line" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "mvn stub failing"; then
  echo "Expected mvn failure output" >&2
  exit 1
fi

echo "[ok] build_modules mvn failure tests passed"
