#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TEST_BIN="${PROJECT_ROOT}/tests_realisation/test_runner"
FAIL_BIN="${PROJECT_ROOT}/tests_realisation/test_failures"

printf '[1/3] Build library\n'
make -C "${PROJECT_ROOT}" re >/dev/null

printf '[2/3] Compile sample suite\n'
cc -Wall -Wextra -Werror -I"${PROJECT_ROOT}/include" \
	"${PROJECT_ROOT}/tests_realisation/test_sample.c" \
	"${PROJECT_ROOT}/libunit.a" -o "${TEST_BIN}"

printf '[3/4] Compile failure suite\n'
cc -Wall -Wextra -Werror -I"${PROJECT_ROOT}/include" \
	"${PROJECT_ROOT}/tests_realisation/test_failures.c" \
	"${PROJECT_ROOT}/libunit.a" -o "${FAIL_BIN}"

printf '[4/4] Run suites\n'
"${TEST_BIN}"
"${FAIL_BIN}"
printf 'Suites passed ✅\n'
