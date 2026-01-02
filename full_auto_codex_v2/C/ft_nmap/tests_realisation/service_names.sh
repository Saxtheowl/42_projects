#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Checking service-name port parsing..."
./ft_nmap -t 127.0.0.1 -p ssh,http,https -n -q -o "$out_json"

grep -q '"port":22' "$out_json" || { echo "missing ssh (22) port"; exit 1; }
grep -q '"port":80' "$out_json" || { echo "missing http (80) port"; exit 1; }
grep -q '"port":443' "$out_json" || { echo "missing https (443) port"; exit 1; }

echo "Service-name ports parsed correctly."
