#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TMP_DIR=""

cleanup() {
	if [[ -n "${TMP_DIR}" && -d "${TMP_DIR}" ]]; then
		rm -rf "${TMP_DIR}"
	fi
}
trap cleanup EXIT

fail() {
	echo "Error: $1" >&2
	exit 1
}

run_with_timeout() {
	local seconds="$1"
	shift
	if command -v timeout >/dev/null 2>&1; then
		timeout "${seconds}s" "$@"
	elif command -v python3 >/dev/null 2>&1; then
		python3 - "$seconds" "$@" <<'PY'
import subprocess
import sys

timeout = float(sys.argv[1])
command = sys.argv[2:]

try:
	result = subprocess.run(command, timeout=timeout)
	sys.exit(result.returncode)
except subprocess.TimeoutExpired:
	sys.exit(124)
PY
	else
		"$@"
	fi
}

echo "[1/4] Build project"
make -C "${PROJECT_ROOT}" re >/dev/null

TMP_DIR="$(mktemp -d)"
LOG_OK="${TMP_DIR}/success.log"
LOG_DEATH="${TMP_DIR}/death.log"

echo "[2/4] Scenario: graceful completion (must eat twice)"
run_with_timeout 10 "${PROJECT_ROOT}/philo" 4 310 100 100 2 >"${LOG_OK}"

if grep -q "died" "${LOG_OK}"; then
	fail "Unexpected death detected in success scenario"
fi

echo "[3/4] Scenario: expected death (single philosopher)"
run_with_timeout 5 "${PROJECT_ROOT}/philo" 1 200 100 100 >"${LOG_DEATH}"

if ! grep -q "died" "${LOG_DEATH}"; then
	fail "Death scenario did not log a death"
fi

echo "[4/4] All checks passed ✅"
