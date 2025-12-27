#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_list="$(mktemp)"
trap 'rm -f "$out_list"' EXIT

echo "Checking open ports list export..."
./ft_nmap -t 127.0.0.1 -p 22,80 -T 200 -q -L "$out_list"

if [ ! -f "$out_list" ]; then
	echo "Open list file not created" >&2
	exit 1
fi

# In sandbox expected empty (no open ports), but file must exist and be writable.
if [ -s "$out_list" ]; then
	# If there is content, ensure it's numeric list
	grep -Eq '^[0-9]+( [[:alnum:]-]+)?$' "$out_list" || { echo "Open list content malformed" >&2; exit 1; }
fi

echo "Open list export test OK."
