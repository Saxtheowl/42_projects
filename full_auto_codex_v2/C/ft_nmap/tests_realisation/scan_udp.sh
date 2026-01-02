#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_sum="$(mktemp)"
trap 'rm -f "$out_sum"' EXIT

echo "Checking UDP scan option parsing..."
./ft_nmap -t 127.0.0.1 -p 53 --scan udp -n -q -J "$out_sum"

grep -q '"stats"' "$out_sum" || { echo "UDP scan JSON missing stats"; exit 1; }

echo "UDP scan option test OK."
