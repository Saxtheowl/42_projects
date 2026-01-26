#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/publish_sample_keys.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

# Copy script into a temp root with stubbed dependencies to avoid real publish.
tmp_root=$(mktemp -d)
cleanup() {
  rm -rf "${tmp_root}"
}
trap cleanup EXIT

mkdir -p "${tmp_root}/scripts"
cp "${SCRIPT}" "${tmp_root}/scripts/publish_sample_keys.sh"

cat > "${tmp_root}/scripts/publish_test_message.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${tmp_root}/scripts/publish_test_message.sh"

cat > "${tmp_root}/scripts/check_prereqs.sh" <<'STUB'
#!/usr/bin/env bash
exit 0
STUB
chmod +x "${tmp_root}/scripts/check_prereqs.sh"

json_output=$(ROUTING_KEYS="grant.test" "${tmp_root}/scripts/publish_sample_keys.sh" --json 2>/dev/null || true)
if ! printf '%s' "${json_output}" | python3 -c 'import json,sys; data=json.loads(sys.stdin.read().strip()); assert data.get("status")=="ok"; assert isinstance(data.get("published"), list)'; then
  echo "Expected publish_sample_keys --json to return status ok and published list." >&2
  exit 1
fi

echo "[ok] publish_sample_keys json tests passed"
