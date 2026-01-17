#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

BIN="$ROOT/ft_mini_ls"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

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

# Build a temp directory with controlled mtimes
cd "$TMP"
mkdir sample
cd sample

touch -t 202001010000.00 oldest
touch -t 202101010000.00 middle
touch -t 202201010000.00 newest
touch -t 202001010100.00 almost_oldest
touch .hidden

run_ls() {
    (cd "$TMP/sample" && ls -1tr)
}
run_mini() {
    (cd "$TMP/sample" && "$BIN")
}

expect_eq "$(run_ls)" "$(run_mini)" "listing matches ls -1tr (order/time, hidden skipped)"

# Empty directory should produce no output
mkdir "$TMP/empty"
empty_expected="$(cd "$TMP/empty" && ls -1tr)"
empty_actual="$(cd "$TMP/empty" && "$BIN")"
expect_eq "$empty_expected" "$empty_actual" "empty directory produces no output"

# Hidden-only directory should also produce no output
mkdir "$TMP/hidden_only"
touch "$TMP/hidden_only/.secret"
hidden_expected="$(cd "$TMP/hidden_only" && ls -1tr)"
hidden_actual="$(cd "$TMP/hidden_only" && "$BIN")"
expect_eq "$hidden_expected" "$hidden_actual" "hidden-only directory produces no output"

# Argument handling
arg_err="$("$BIN" arg1 2>&1 || true)"
if "$BIN" arg1 >/dev/null 2>&1; then
    echo "❌ program should fail when passed arguments"
    failures=$((failures + 1))
else
    echo "✅ arguments produce an error as expected"
fi
if ! grep -q "takes no arguments" <<<"$arg_err"; then
    echo "❌ arguments error message missing"
    failures=$((failures + 1))
else
    echo "✅ arguments error message ok"
fi

echo
if [[ $failures -eq 0 ]]; then
    echo "All tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
