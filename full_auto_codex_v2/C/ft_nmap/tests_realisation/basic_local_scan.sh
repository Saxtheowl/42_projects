#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

echo "Scanning localhost common ports (22,80,443) with 200ms timeout..."
./ft_nmap -t 127.0.0.1 -p 22,80,443 -T 200 -c 64 -S -l -o out.json -C out.csv
