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

output="$(MODULES="producer,services/producer" "${ROOT_DIR}/scripts/build_modules.sh" 2>&1)"
count="$(echo "${output}" | grep -c "Building services/producer")"
if [ "${count}" -ne 1 ]; then
  echo "Expected producer built once, got ${count}" >&2
  exit 1
fi

if echo "${output}" | grep -q "financial_assistance"; then
  echo "Unexpected module built" >&2
  exit 1
fi

echo "[ok] build_modules duplicate targets tests passed"
