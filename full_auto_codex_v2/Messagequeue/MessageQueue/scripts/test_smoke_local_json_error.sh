#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/smoke_local.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

mkdir -p "${stub_dir}/bin"

cat > "${stub_dir}/bin/docker" <<'STUB'
#!/usr/bin/env bash
exit 1
STUB
chmod +x "${stub_dir}/bin/docker"

output=$(PATH="${stub_dir}/bin:$PATH" "${SCRIPT}" --json || true)
if [[ -z "${output}" ]]; then
  echo "Expected JSON output." >&2
  exit 1
fi
if ! printf '%s' "${output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status") == "error"; assert data.get("step") in ("docker","docker_compose")'; then
  echo "smoke_local JSON error output unexpected." >&2
  exit 1
fi

echo "[ok] smoke_local json error tests passed"
