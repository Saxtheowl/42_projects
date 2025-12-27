#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

echo "Checking version output..."
output="$(./ft_nmap -V)"
ret=$?
if [ $ret -ne 0 ]; then
  echo "ft_nmap -V should exit 0, got $ret"
  exit 1
fi
echo "$output" | grep -q "ft_nmap " || { echo "Version string missing prefix"; exit 1; }
echo "$output" | grep -qE 'ft_nmap [0-9]+\.[0-9]+\.[0-9]+' || { echo "Version string missing semver pattern"; exit 1; }
echo "Version flag OK."
