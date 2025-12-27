#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

tmp_err="$(mktemp)"
trap 'rm -f "$tmp_err"' EXIT

echo "Checking periodic progress output..."
./ft_nmap -t 127.0.0.1 -p 1-200 -T 50 -c 32 -q -g 50 2> "$tmp_err" >/dev/null

if ! grep -q "\\[progress\\]" "$tmp_err"; then
	echo "No progress lines were emitted"
	exit 1
fi
if ! grep -q "scanned=" "$tmp_err"; then
	echo "Progress lines missing counters"
	exit 1
fi

echo "Progress test OK."
