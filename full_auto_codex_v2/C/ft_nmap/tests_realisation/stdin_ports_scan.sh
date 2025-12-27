#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

echo "Scanning ports from stdin (22,80,443) with -P - ..."
printf '22\n80\n443\n' | ./ft_nmap -t 127.0.0.1 -P - -T 200 -q
