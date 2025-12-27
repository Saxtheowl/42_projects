#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."
make >/dev/null

tmp1="$(mktemp)"
tmp2="$(mktemp)"
trap 'rm -f "$tmp1" "$tmp2"' EXIT

echo "Checking deterministic random seed support..."
./ft_nmap -t 127.0.0.1 -p 22,80,443 -r -e 123 -q -o "$tmp1"
./ft_nmap -t 127.0.0.1 -p 22,80,443 -r -q -o "$tmp2"

python3 - "$tmp1" "$tmp2" <<'PY'
import json, sys
with open(sys.argv[1], "r", encoding="utf-8") as f:
    seed_json = json.load(f)
with open(sys.argv[2], "r", encoding="utf-8") as f:
    auto_json = json.load(f)

s1 = seed_json["stats"]
if not s1.get("randomized"):
    print("Expected randomized=true when -r/-e are provided", file=sys.stderr)
    sys.exit(1)
if s1.get("random_seed") != 123:
    print(f"Expected random_seed=123, got {s1.get('random_seed')}", file=sys.stderr)
    sys.exit(1)

s2 = auto_json["stats"]
if not s2.get("randomized"):
    print("Expected randomized=true when -r is provided", file=sys.stderr)
    sys.exit(1)
auto_seed = s2.get("random_seed")
if auto_seed is None or int(auto_seed) <= 0:
    print(f"Expected a non-zero random_seed when randomized automatically, got {auto_seed}", file=sys.stderr)
    sys.exit(1)
PY

echo "Random seed test OK."
