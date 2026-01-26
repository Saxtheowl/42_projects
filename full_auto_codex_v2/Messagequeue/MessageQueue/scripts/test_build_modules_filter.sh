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

output="$(MODULES="producer,contracts" "${ROOT_DIR}/scripts/build_modules.sh" 2>&1)"
if ! echo "${output}" | grep -q "Building services/producer"; then
  echo "Expected producer build" >&2
  exit 1
fi
if ! echo "${output}" | grep -q "Building services/consumers/contracts"; then
  echo "Expected contracts build" >&2
  exit 1
fi
if echo "${output}" | grep -q "transportation_costs"; then
  echo "Unexpected module built" >&2
  exit 1
fi

output_path="$(MODULES="services/consumers/financial_assistance" "${ROOT_DIR}/scripts/build_modules.sh" 2>&1)"
if ! echo "${output_path}" | grep -q "Building services/consumers/financial_assistance"; then
  echo "Expected financial_assistance build" >&2
  exit 1
fi

if ! echo "${output_path}" | grep -q "mvn stub"; then
  echo "Expected mvn stub usage" >&2
  exit 1
fi

echo "[ok] build_modules filter tests passed"
