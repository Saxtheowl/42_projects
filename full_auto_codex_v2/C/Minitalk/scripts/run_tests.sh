#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SERVER_LOG=""
SERVER_PROCESS=""

cleanup() {
	if [[ -n "${SERVER_PROCESS}" ]]; then
		kill "${SERVER_PROCESS}" >/dev/null 2>&1 || true
		wait "${SERVER_PROCESS}" 2>/dev/null || true
	fi
	if [[ -n "${SERVER_LOG}" && -f "${SERVER_LOG}" ]]; then
		rm -f "${SERVER_LOG}"
	fi
}
trap cleanup EXIT

echo "[1/4] Build binaries"
make -C "${PROJECT_ROOT}" re >/dev/null

SERVER_LOG="$(mktemp)"
echo "[2/4] Launch server (log: ${SERVER_LOG})"
"${PROJECT_ROOT}/server" >"${SERVER_LOG}" &
SERVER_PROCESS=$!

SERVER_PID=""
for _ in {1..100}; do
	if grep -q "Server PID:" "${SERVER_LOG}"; then
		SERVER_PID="$(awk '/Server PID:/ {print $NF; exit}' "${SERVER_LOG}")"
		if [[ -n "${SERVER_PID}" ]]; then
			break
		fi
	fi
	sleep 0.05
done

if [[ -z "${SERVER_PID}" ]]; then
	echo "Error: failed to read server PID from log ${SERVER_LOG}" >&2
	exit 1
fi

echo "[3/4] Send messages through client"
"${PROJECT_ROOT}/client" >/dev/null 2>&1 && {
	echo "Error: client should fail without args" >&2
	exit 1
}
if ! "${PROJECT_ROOT}/client" "abc" "Hello" 2>"${SERVER_LOG}.err"; then
	if ! grep -q "Error: invalid server PID" "${SERVER_LOG}.err"; then
		echo "Error: invalid PID message missing" >&2
		exit 1
	fi
else
	echo "Error: client should fail for invalid PID" >&2
	exit 1
fi
if ! "${PROJECT_ROOT}/client" 999999 "Hello" 2>"${SERVER_LOG}.err"; then
	if ! grep -q "Error: cannot reach server" "${SERVER_LOG}.err"; then
		echo "Error: unreachable PID message missing" >&2
		exit 1
	fi
else
	echo "Error: client should fail for unreachable PID" >&2
	exit 1
fi
"${PROJECT_ROOT}/client" "${SERVER_PID}" "Hello from automated test!"
"${PROJECT_ROOT}/client" "${SERVER_PID}" ""
"${PROJECT_ROOT}/client" "${SERVER_PID}" "Ping? 42!"
"${PROJECT_ROOT}/client" "${SERVER_PID}" "Quick one"
"${PROJECT_ROOT}/client" "${SERVER_PID}" "Quick two"

sleep 0.2

if ! grep -q "Hello from automated test!" "${SERVER_LOG}"; then
	echo "Error: server log does not contain expected message" >&2
	exit 1
fi
if ! grep -q "Ping? 42!" "${SERVER_LOG}"; then
	echo "Error: server log does not contain punctuation test" >&2
	exit 1
fi
if ! grep -q "Quick one" "${SERVER_LOG}"; then
	echo "Error: server log does not contain quick message one" >&2
	exit 1
fi
if ! grep -q "Quick two" "${SERVER_LOG}"; then
	echo "Error: server log does not contain quick message two" >&2
	exit 1
fi

if ! awk 'NF == 0 {found = 1} END {exit !found}' "${SERVER_LOG}"; then
	echo "Error: empty message did not produce a blank line" >&2
	exit 1
fi

echo "[4/4] All checks passed ✅"
