#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

BIN="$ROOT/ft_shield"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

HOME="$TMP" "$BIN" -c "echo decoy_output" >"$TMP/out.txt"
HOME="$TMP" "$BIN" -c "echo decoy_again" -i "source ~/.ft_shield/ft_shield.bin >/dev/null 2>&1" >/dev/null

failures=0
set +e
HOME="$TMP" "$BIN" -c "sh -c 'exit 7'"
exit_code=$?
set -e
if [[ $exit_code -ne 7 ]]; then
    echo "❌ exit code not propagated (expected 7, got $exit_code)"
    failures=$((failures + 1))
else
    echo "✅ exit code propagated"
fi

set +e
usage_output=$(HOME="$TMP" "$BIN" -x 2>&1)
usage_code=$?
set -e
if [[ $usage_code -eq 0 ]]; then
    echo "❌ invalid option should fail"
    failures=$((failures + 1))
else
    echo "✅ invalid option fails"
fi
if ! grep -q "usage:" <<<"$usage_output"; then
    echo "❌ usage message missing"
    failures=$((failures + 1))
else
    echo "✅ usage message ok"
fi

if ! grep -q "decoy_output" "$TMP/out.txt"; then
    echo "❌ decoy command output missing"
    failures=$((failures + 1))
else
    echo "✅ decoy command output"
fi

if [[ ! -f "$TMP/.ft_shield/ft_shield.bin" ]]; then
    echo "❌ self copy missing"
    failures=$((failures + 1))
else
    echo "✅ self copy created"
fi

if [[ ! -f "$TMP/.ft_shield/log.txt" ]]; then
    echo "❌ log missing"
    failures=$((failures + 1))
else
    if grep -q "FT_SHIELD_LOG" "$TMP/.ft_shield/log.txt"; then
        echo "✅ log contains marker"
    else
        echo "❌ log missing marker"
        failures=$((failures + 1))
    fi
fi

if grep -q "source ~/.ft_shield/ft_shield.bin" "$TMP/.bashrc"; then
    echo "✅ hook added to bashrc"
else
    echo "❌ hook not added to bashrc"
    failures=$((failures + 1))
fi

echo
if [[ $failures -eq 0 ]]; then
    echo "All tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
