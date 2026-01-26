#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
SCRIPT="${ROOT_DIR}/scripts/setup_env.sh"

if [[ ! -x "${SCRIPT}" ]]; then
  echo "Missing ${SCRIPT}" >&2
  exit 1
fi

work_dir=$(mktemp -d)
cleanup() {
  rm -rf "${work_dir}"
}
trap cleanup EXIT

# Missing source should fail.
if SRC="${work_dir}/missing.env" DST="${work_dir}/.env" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected setup_env to fail when source is missing." >&2
  exit 1
fi

# Should copy when dst missing.
src_file="${work_dir}/.env.example"
cat > "${src_file}" <<'ENV'
FOO=bar
ENV
if ! SRC="${src_file}" DST="${work_dir}/.env" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected setup_env to create dst from src." >&2
  exit 1
fi
if [[ ! -f "${work_dir}/.env" ]]; then
  echo "Expected dst .env to be created." >&2
  exit 1
fi

# Should be no-op when dst exists.
if ! SRC="${src_file}" DST="${work_dir}/.env" "${SCRIPT}" >/dev/null 2>&1; then
  echo "Expected setup_env to succeed when dst already exists." >&2
  exit 1
fi

echo "[ok] setup_env tests passed"
