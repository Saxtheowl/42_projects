#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BUILD_DIR="${PROJECT_ROOT}/build"
TEST_DIR="${PROJECT_ROOT}/tests_realisation"
TEST_BIN="${TEST_DIR}/test_runner"

printf '[1/3] Build library\n'
make -C "${PROJECT_ROOT}" re >/dev/null

printf '[2/3] Compile test harness\n'
cc -Wall -Wextra -Werror -I"${PROJECT_ROOT}/include" \
	"${TEST_DIR}/test_main.c" "${PROJECT_ROOT}/libftprintf.a" -o "${TEST_BIN}"

printf '[3/3] Run tests\n'
"${TEST_BIN}"
printf 'All tests passed ✅\n'
