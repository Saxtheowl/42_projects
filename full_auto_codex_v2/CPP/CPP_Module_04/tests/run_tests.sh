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
out=$("$ROOT/ex00/animals")
expect_contains "$out" "Woof!" "ex00 dog sound"
expect_contains "$out" "Meow!" "ex00 cat sound"

make -C "$ROOT/ex01" >/dev/null
out=$("$ROOT/ex01/animals_brain")
expect_contains "$out" "Brain ctor" "ex01 brain ctor"

make -C "$ROOT/ex02" >/dev/null
out=$("$ROOT/ex02/aanimals")
expect_contains "$out" "AAnimal default ctor" "ex02 abstract ctor"

make -C "$ROOT/ex03" >/dev/null
out=$("$ROOT/ex03/materia")
expect_contains "$out" "ice bolt" "ex03 ice use"
expect_contains "$out" "heals bob" "ex03 cure use"

make -C "$ROOT/ex04" >/dev/null
out=$("$ROOT/ex04/mines")
expect_contains "$out" "ice bolt" "ex04 ice use"
expect_contains "$out" "heals bob" "ex04 cure use"

echo
if [[ $failures -eq 0 ]]; then
    echo "All CPP Module 04 tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
