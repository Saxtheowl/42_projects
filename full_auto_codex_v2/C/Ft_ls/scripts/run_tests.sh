#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
FIXTURES_DIR="${PROJECT_ROOT}/tests_realisation/fixtures"
FT_LS_BIN="${PROJECT_ROOT}/ft_ls"
SYSTEM_LS="/bin/ls"

if [[ ! -x ${SYSTEM_LS} ]]; then
	echo "Error: /bin/ls not found" >&2
	exit 1
fi

printf '[1/3] Build project\n'
make -C "${PROJECT_ROOT}" re >/dev/null

TMP_DIR="$(mktemp -d)"
cleanup() {
	rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

run_case() {
	local name="$1"
	shift
	local args=("$@")
	local our_out="${TMP_DIR}/ft_ls_${name}.out"
	local ref_out="${TMP_DIR}/ls_${name}.out"

	( cd "${FIXTURES_DIR}" && env LC_ALL=C "${FT_LS_BIN}" "${args[@]}" | sed -E "s/[ ]+/ /g" >"${our_out}" )
	( cd "${FIXTURES_DIR}" && env LC_ALL=C "${SYSTEM_LS}" "${args[@]}" | sed -E "s/[ ]+/ /g" >"${ref_out}" )

	if ! diff -u "${ref_out}" "${our_out}" >"${TMP_DIR}/diff_${name}.txt"; then
		printf '[FAIL] %s\n' "${name}" >&2
		cat "${TMP_DIR}/diff_${name}.txt" >&2
		return 1
	fi
	printf '[OK]   %s\n' "${name}"
	return 0
}

printf '[2/3] Run comparison suite\n'
run_case "default"              "."
run_case "all"                   "-a" "."
run_case "long"                  "-l" "."
run_case "long_all"              "-la" "."
run_case "reverse"               "-r" "."
run_case "time"                  "-t" "."
run_case "recurse"               "-R" "."
run_case "mixed"                 "-l" "file_a.txt" "dir_nested" "dir_empty"

printf '[3/3] All tests passed ✅\n'
