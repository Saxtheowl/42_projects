#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/check_prereqs.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

# Use a stubbed docker to force missing docker compose.
stub_dir=$(mktemp -d)
cleanup() {
  rm -rf "${stub_dir}"
}
trap cleanup EXIT

cat > "${stub_dir}/docker" <<'STUB'
#!/usr/bin/env bash
if [[ "$1" == "compose" ]]; then
  exit 1
fi
exit 0
STUB
chmod +x "${stub_dir}/docker"

json_output=$(PATH="${stub_dir}:$PATH" SKIP_DOCKER=0 SKIP_MVN=1 "${SCRIPT}" --json 2>/dev/null || true)
if [[ -z "${json_output}" ]]; then
  echo "Expected JSON output from check_prereqs --json." >&2
  exit 1
fi
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="error"; assert "docker compose" in data.get("missing",[])'; then
  echo "Expected check_prereqs --json to report missing docker compose." >&2
  exit 1
fi

echo "[ok] check_prereqs json missing tests passed"
