#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TMP_DIR="${PROJECT_ROOT}/tests_realisation/tmp"
mkdir -p "${TMP_DIR}"

printf '[1/4] Build project\n'
make -C "${PROJECT_ROOT}" re >/dev/null

printf '[2/4] Run binary\n'
if ! "${PROJECT_ROOT}/ft_containers" >"${TMP_DIR}/output.log" 2>&1; then
	printf '[FAIL] executable returned non-zero exit code\n' >&2
	exit 1
fi
printf '[OK] executable run\n'

printf '[3/4] Inspect output\n'
if ! grep -q 'ft_containers skeleton' "${TMP_DIR}/output.log"; then
	printf '[FAIL] expected banner missing\n' >&2
	exit 1
fi
if ! grep -q 'vector size=2 front=42 back=21' "${TMP_DIR}/output.log"; then
	printf '[FAIL] vector smoke check failed\n' >&2
	exit 1
fi
printf '[OK] output checks\n'

printf '[4/4] std vs ft comparison\n'
TESTS=(
	vector_compare
	list_compare
	map_compare
	list_stack_queue_compare
)

for test in "${TESTS[@]}"; do
	printf '  - %s\n' "${test}"
	src="${PROJECT_ROOT}/tests_realisation/${test}.cpp"
	ft_bin="${TMP_DIR}/${test}_ft"
	std_bin="${TMP_DIR}/${test}_std"
	ft_out="${TMP_DIR}/${test}_ft.out"
	std_out="${TMP_DIR}/${test}_std.out"

	g++ -Wall -Wextra -Werror -std=c++98 -I"${PROJECT_ROOT}/include" \
		-DUSE_FT -o "${ft_bin}" "${src}"
	g++ -Wall -Wextra -Werror -std=c++98 -o "${std_bin}" "${src}"

	"${ft_bin}" > "${ft_out}"
	"${std_bin}" > "${std_out}"
	if ! diff -u "${std_out}" "${ft_out}" >/dev/null; then
		printf '[FAIL] mismatch detected in %s\n' "${test}" >&2
		diff -u "${std_out}" "${ft_out}" >&2 || true
		exit 1
	fi
done
printf '[OK] comparison match\n'

printf 'Smoke tests passed ✅\n'
