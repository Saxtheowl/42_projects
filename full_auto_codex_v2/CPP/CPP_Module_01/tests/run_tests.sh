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
out=$("$ROOT/ex00/zombieland")
if echo "$out" | grep -q "Heapster: BraiiiiiiinnnzzzZ..."; then
    echo "✅ ex00 output includes heap zombie"
else
    echo "❌ ex00 output missing heap zombie"
    failures=$((failures + 1))
fi

make -C "$ROOT/ex01" >/dev/null
out=$("$ROOT/ex01/horde")
count=$(echo "$out" | grep -c "Walker: BraiiiiiiinnnzzzZ...")
expect_eq "5" "$count" "ex01 zombie horde count"

make -C "$ROOT/ex02" >/dev/null
out=$("$ROOT/ex02/brain")
addr_count=$(echo "$out" | head -n 3 | sort | uniq | wc -l)
expect_eq "1" "$addr_count" "ex02 address consistency"

make -C "$ROOT/ex03" >/dev/null
out=$("$ROOT/ex03/violence")
expected=$'Bob attacks with their crude spiked club\nBob attacks with their some other type of club\nJim attacks with their crude spiked club\nJim attacks with their some other type of club'
if echo "$out" | grep -q "Jim attacks with their crude spiked club"; then
    echo "✅ ex03 weapon reassignment output"
else
    echo "❌ ex03 output missing reassignment"
    failures=$((failures + 1))
fi

make -C "$ROOT/ex04" >/dev/null
tmp_dir="$(mktemp -d)"
tmp_file="$tmp_dir/input.txt"
printf "foo bar foo" > "$tmp_file"
"$ROOT/ex04/sed_is_for_losers" "$tmp_file" "foo" "baz" >/dev/null
if [[ -f "${tmp_file}.replace" ]]; then
    out=$(cat "${tmp_file}.replace")
    expect_eq "baz bar baz" "$out" "ex04 replace output"
else
    echo "❌ ex04 output file missing"
    failures=$((failures + 1))
fi
rm -rf "$tmp_dir"

make -C "$ROOT/ex05" >/dev/null
out=$("$ROOT/ex05/harl")
if echo "$out" | grep -q "\\[ DEBUG \\]" && echo "$out" | grep -q "\\[ ERROR \\]"; then
    echo "✅ ex05 Harl levels output"
else
    echo "❌ ex05 output missing expected levels"
    failures=$((failures + 1))
fi

make -C "$ROOT/ex06" >/dev/null
out=$("$ROOT/ex06/harl_filter" WARNING)
if echo "$out" | grep -q "\\[ WARNING \\]" && echo "$out" | grep -q "\\[ ERROR \\]"; then
    echo "✅ ex06 filter outputs warning+error"
else
    echo "❌ ex06 filter output missing expected levels"
    failures=$((failures + 1))
fi

echo
if [[ $failures -eq 0 ]]; then
    echo "All CPP Module 01 tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
