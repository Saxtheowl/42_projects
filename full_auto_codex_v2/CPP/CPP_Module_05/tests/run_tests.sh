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
out=$("$ROOT/ex00/bureaucrat")
expect_contains "$out" "Grade too low" "ex00 low grade exception"
expect_contains "$out" "Grade too high" "ex00 high grade exception"

make -C "$ROOT/ex01" >/dev/null
out=$("$ROOT/ex01/forms")
expect_contains "$out" "couldn’t sign FormA" "ex01 sign failure"

make -C "$ROOT/ex02" >/dev/null
out=$("$ROOT/ex02/forms")
expect_contains "$out" "drilling noises" "ex02 robotomy noise"
expect_contains "$out" "executed ShrubberyCreation" "ex02 shrubbery execution"

make -C "$ROOT/ex03" >/dev/null
out=$("$ROOT/ex03/forms")
expect_contains "$out" "Intern creates shrubbery creation" "ex03 intern creates shrubbery"
expect_contains "$out" "Unknown form name" "ex03 unknown form"

echo
if [[ $failures -eq 0 ]]; then
    echo "All CPP Module 05 tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
