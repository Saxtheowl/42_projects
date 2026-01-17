#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
failures=0

expect_eq() {
    local expected="$1"
    local actual="$2"
    local label="$3"
    if [[ "$expected" != "$actual" ]]; then
        echo "❌ $label"
        echo "   expected: $expected"
        echo "   actual  : $actual"
        failures=$((failures + 1))
    else
        echo "✅ $label"
    fi
}

make -C "$ROOT/ex00" >/dev/null
out=$("$ROOT/ex00/megaphone")
expect_eq "* LOUD AND UNBEARABLE FEEDBACK NOISE *" "$out" "ex00 no-args message"
out=$("$ROOT/ex00/megaphone" "aBcd" "Ef")
expect_eq "ABCDEF" "$out" "ex00 uppercase arguments"

make -C "$ROOT/ex02" >/dev/null
out=$("$ROOT/ex02/tests_account" 2>/dev/null || true)
if echo "$out" | grep -q "accounts:2;total:"; then
    echo "✅ ex02 summary output"
else
    echo "❌ ex02 summary output missing"
    failures=$((failures + 1))
fi

make -C "$ROOT/ex01" >/dev/null
printf "Bob\nDylan\nSinger\n" | "$ROOT/ex01/phonebook" >/dev/null 2>&1 || true
printf "ADD\nBob\nDylan\nSinger\n0123456789\nsecret\nSEARCH\n0\nEXIT\n" | "$ROOT/ex01/phonebook" > "$ROOT/tests/ex01_out.txt"
if grep -q "Bob" "$ROOT/tests/ex01_out.txt"; then
    echo "✅ ex01 add/search output"
else
    echo "❌ ex01 add/search output missing"
    failures=$((failures + 1))
fi
rm -f "$ROOT/tests/ex01_out.txt"

make -C "$ROOT/ex03" >/dev/null
out=$("$ROOT/ex03/attack")
expected=$'Bob attacks with their crude spiked club\nBob attacks with their some other type of club\nJim attacks with bare hands\nJim attacks with their crude spiked club\nJim attacks with their some other type of club'
expect_eq "$expected" "$out" "ex03 attack output"

make -C "$ROOT/ex04" >/dev/null
tmp_dir="$(mktemp -d)"
tmp_file="$tmp_dir/input.txt"
printf "foo bar foo" > "$tmp_file"
"$ROOT/ex04/replace" "$tmp_file" "foo" "baz" >/dev/null
if [[ -f "${tmp_file}.replace" ]]; then
    out=$(cat "${tmp_file}.replace")
    expect_eq "baz bar baz" "$out" "ex04 replace output"
else
    echo "❌ ex04 output file missing"
    failures=$((failures + 1))
fi
rm -rf "$tmp_dir"

echo
if [[ $failures -eq 0 ]]; then
    echo "All CPP Module 00 tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
