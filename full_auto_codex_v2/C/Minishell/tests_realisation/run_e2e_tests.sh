#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "${ASAN_OPTIONS:-}" ]]; then
  export ASAN_OPTIONS=detect_leaks=0
fi
if [[ -z "${LSAN_OPTIONS:-}" ]]; then
  export LSAN_OPTIONS=detect_leaks=0
fi

python3 "${SCRIPT_DIR}/e2e_tests.py"
