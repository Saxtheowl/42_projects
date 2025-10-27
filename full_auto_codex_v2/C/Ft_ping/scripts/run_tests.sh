#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
BINARY="${PROJECT_ROOT}/ft_ping"

printf '[1/2] Build project\n'
make -C "${PROJECT_ROOT}" re >/dev/null

TMP_DIR="${PROJECT_ROOT}/tests_realisation/tmp"
mkdir -p "${TMP_DIR}"

printf '[2/2] Run smoke tests\n'
usage_output="$("${BINARY}" 2>&1 || true)"
if printf '%s' "${usage_output}" | grep -iq "usage"; then
	printf '[OK] usage message\n'
else
	printf '[FAIL] usage message missing\n'
	exit 1
fi

OUTPUT_FILE="${TMP_DIR}/ft_ping_privilege.out"
if "${BINARY}" 127.0.0.1 >"${OUTPUT_FILE}" 2>&1; then
	printf '[FAIL] expected privileged error\n'
	exit 1
fi
if grep -qi "requires root" "${OUTPUT_FILE}"; then
	printf '[OK] privilege check\n'
else
	printf '[FAIL] privilege check message missing\n'
	exit 1
fi
printf 'Smoke tests passed ✅\n'
