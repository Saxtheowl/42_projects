#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

expect_contains() {
    local haystack="$1"
    local needle="$2"
    local label="$3"
    if echo "$haystack" | grep -q "$needle"; then
        echo "✅ $label"
    else
        echo "❌ $label"
        failures=$((failures + 1))
    fi
}

make -C "$ROOT/ex00" >/dev/null
out=$("$ROOT/ex00/claptrap")
expect_contains "$out" "ClapTrap A attacks B" "ex00 attack output"

make -C "$ROOT/ex01" >/dev/null
out=$("$ROOT/ex01/scavtrap")
expect_contains "$out" "Gate keeper mode" "ex01 gate keeper"

make -C "$ROOT/ex02" >/dev/null
out=$("$ROOT/ex02/fragtrap")
expect_contains "$out" "requests high fives" "ex02 high fives"

make -C "$ROOT/ex03" >/dev/null
out=$("$ROOT/ex03/diamondtrap")
expect_contains "$out" "I am Diamondy" "ex03 whoAmI"

echo
if [[ $failures -eq 0 ]]; then
    echo "All CPP Module 03 tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
