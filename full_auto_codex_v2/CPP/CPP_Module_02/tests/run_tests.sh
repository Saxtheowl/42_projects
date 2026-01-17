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
out=$("$ROOT/ex00/fixed0")
expect_contains "$out" "Default constructor called" "ex00 default constructor"
expect_contains "$out" "getRawBits member function called" "ex00 getRawBits"

make -C "$ROOT/ex01" >/dev/null
out=$("$ROOT/ex01/fixed1")
expect_contains "$out" "a is 1234.43" "ex01 float output"
expect_contains "$out" "a is 1234 as integer" "ex01 int output"

make -C "$ROOT/ex02" >/dev/null
out=$("$ROOT/ex02/fixed2")
expect_contains "$out" "10.1016" "ex02 final value"

make -C "$ROOT/ex03" >/dev/null
out=$("$ROOT/ex03/bsp")
expect_contains "$out" "p1 inside? yes" "ex03 inside point"
expect_contains "$out" "p2 inside? no" "ex03 outside point"

echo
if [[ $failures -eq 0 ]]; then
    echo "All CPP Module 02 tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
