#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

out_json="$(mktemp)"
trap 'rm -f "$out_json"' EXIT

echo "Checking JSON export to stdout with -Q..."
# quiet + summary to stderr to keep stdout clean
./ft_nmap -t 127.0.0.1 -p 22,80 -T 200 -q -Q -o - >"$out_json"

if [ ! -s "$out_json" ]; then
	echo "JSON stdout is empty" >&2
	exit 1
fi

python3 - <<'PY' "$out_json"
import json, sys
path = sys.argv[1]
with open(path) as f:
    data = json.load(f)
assert "target" in data and "ports" in data and "stats" in data, "Missing keys in JSON stdout"
assert isinstance(data["ports"], list), "ports should be a list"
print("JSON stdout parsed OK.")
PY

echo "JSON stdout export test OK."
