#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/append_log.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "${tmp_dir}"
}
trap cleanup EXIT

cp "${SCRIPT}" "${tmp_dir}/append_log.sh"
chmod +x "${tmp_dir}/append_log.sh"

: > "${tmp_dir}/progress.md"
: > "${tmp_dir}/README.md"

(
  cd "${tmp_dir}"
  ./append_log.sh "2026-01-25 19:10:00" "Messagequeue/MessageQueue" "IN_PROGRESS" "test append"
)

if ! rg -q "2026-01-25 19:10:00 \| Messagequeue/MessageQueue \| IN_PROGRESS \| test append" "${tmp_dir}/progress.md"; then
  echo "Expected progress.md line to be appended." >&2
  exit 1
fi
if ! rg -q "Derniere mise a jour \(2026-01-25 19:10:00\) : Messagequeue/MessageQueue IN_PROGRESS : test append" "${tmp_dir}/README.md"; then
  echo "Expected README.md line to be appended." >&2
  exit 1
fi

echo "[ok] append_log tests passed"
