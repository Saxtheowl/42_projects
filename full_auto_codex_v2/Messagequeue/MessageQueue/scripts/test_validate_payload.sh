#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="${ROOT}/scripts/validate_payload.py"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "${tmp_dir}"' EXIT

json_output=0
failures=0
results=()

for arg in "$@"; do
  if [[ "${arg}" == "--help" ]]; then
    cat <<'EOF'
Usage: ./scripts/test_validate_payload.sh [--help] [--json]
EOF
    exit 0
  elif [[ "${arg}" == "--json" ]]; then
    json_output=1
  else
    echo "Unknown option: ${arg}" >&2
    exit 1
  fi
done

record_result() {
  local label="$1"
  local expected="$2"
  local status="$3"
  results+=("${label}:${expected}:${status}")
}

fail() {
  if [[ "${json_output}" -eq 1 ]]; then
    failures=1
    return
  fi
  echo "[fail] $1" >&2
  exit 1
}

expect_success() {
  local file="$1"
  local label="$2"
  if PAYLOAD_FILE="${file}" "${SCRIPT}" >/dev/null; then
    record_result "${label}" "success" "ok"
  else
    record_result "${label}" "success" "error"
    fail "expected success for ${file}"
  fi
}

expect_failure() {
  local file="$1"
  local label="$2"
  if PAYLOAD_FILE="${file}" "${SCRIPT}" >/dev/null 2>&1; then
    record_result "${label}" "failure" "error"
    fail "expected failure for ${file}"
  else
    record_result "${label}" "failure" "ok"
  fi
}

cat >"${tmp_dir}/valid.json" <<'JSON'
{
  "studentId": "S-0002",
  "firstName": "Grace",
  "lastName": "Hopper",
  "email": "grace.hopper@example.com",
  "grantType": "grant.1.contract"
}
JSON

cat >"${tmp_dir}/missing_grant.json" <<'JSON'
{
  "studentId": "S-0003",
  "firstName": "Alan",
  "lastName": "Turing",
  "email": "alan.turing@example.com"
}
JSON

cat >"${tmp_dir}/bad_grant.json" <<'JSON'
{
  "studentId": "S-0004",
  "firstName": "Katherine",
  "lastName": "Johnson",
  "email": "katherine.johnson@example.com",
  "grantType": "contract"
}
JSON

cat >"${tmp_dir}/bad_grant_empty_part.json" <<'JSON'
{
  "studentId": "S-0005",
  "firstName": "Edsger",
  "lastName": "Dijkstra",
  "email": "edsger.dijkstra@example.com",
  "grantType": "grant..contract"
}
JSON

expect_success "${tmp_dir}/valid.json" "valid"
expect_failure "${tmp_dir}/missing_grant.json" "missing_grant"
expect_failure "${tmp_dir}/bad_grant.json" "bad_grant"
expect_failure "${tmp_dir}/bad_grant_empty_part.json" "bad_grant_empty_part"

if [[ "${json_output}" -eq 1 ]]; then
  RESULTS_JSON="$(printf '%s\n' "${results[@]}")" FAILURES="${failures}" python3 - <<'PY'
import json,os
raw=os.environ.get("RESULTS_JSON","").splitlines()
items=[]
for line in raw:
    if not line.strip():
        continue
    label,expected,status=line.split(":",2)
    items.append({"case": label, "expected": expected, "status": status})
failed=os.environ.get("FAILURES","0") == "1"
print(json.dumps({"status": "error" if failed else "ok", "results": items}))
PY
  exit "${failures}"
fi

echo "[ok] validate_payload tests passed"
