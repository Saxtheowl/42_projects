#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

echo "Checking max port limit enforcement..."
if ./ft_nmap -t 127.0.0.1 -p 1-2000 -n -q >/dev/null 2>&1; then
	echo "Expected failure when exceeding max port limit"
	exit 1
fi

echo "Port limit test OK."
