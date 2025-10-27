#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

printf '[1/3] Build project\n'
make -C "${PROJECT_ROOT}" re >/dev/null

printf '[2/3] Run binary\n'
if ! "${PROJECT_ROOT}/ft_containers" >"${PROJECT_ROOT}/tests_realisation/tmp/output.log" 2>&1; then
	printf '[FAIL] executable returned non-zero exit code\n' >&2
	exit 1
fi
printf '[OK] executable run\n'

printf '[3/3] Inspect output\n'
if ! grep -q 'ft_containers skeleton' "${PROJECT_ROOT}/tests_realisation/tmp/output.log"; then
	printf '[FAIL] expected banner missing\n' >&2
	exit 1
fi
if ! grep -q 'vector size=2 front=42 back=21' "${PROJECT_ROOT}/tests_realisation/tmp/output.log"; then
	printf '[FAIL] vector smoke check failed\n' >&2
	exit 1
fi
printf '[OK] output checks\n'

printf '[4/4] std vs ft comparison\n'
FT_BIN="${PROJECT_ROOT}/tests_realisation/tmp/vector_ft"
STD_BIN="${PROJECT_ROOT}/tests_realisation/tmp/vector_std"
g++ -Wall -Wextra -Werror -std=c++98 -I"${PROJECT_ROOT}/include" \
    -DUSE_FT -o "${FT_BIN}" "${PROJECT_ROOT}/tests_realisation/vector_compare.cpp"
g++ -Wall -Wextra -Werror -std=c++98 -o "${STD_BIN}" \
    "${PROJECT_ROOT}/tests_realisation/vector_compare.cpp"
"${FT_BIN}" > "${PROJECT_ROOT}/tests_realisation/tmp/ft.out"
"${STD_BIN}" > "${PROJECT_ROOT}/tests_realisation/tmp/std.out"
if ! diff -u "${PROJECT_ROOT}/tests_realisation/tmp/std.out" \
        "${PROJECT_ROOT}/tests_realisation/tmp/ft.out" >/dev/null; then
	printf '[FAIL] std/ft outputs differ\n' >&2
	diff -u "${PROJECT_ROOT}/tests_realisation/tmp/std.out" \
		"${PROJECT_ROOT}/tests_realisation/tmp/ft.out" >&2 || true
	exit 1
fi
printf '[OK] comparison match\n'

printf 'Smoke tests passed ✅\n'
