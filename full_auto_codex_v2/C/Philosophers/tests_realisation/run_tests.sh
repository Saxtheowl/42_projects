#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

BIN="$ROOT/philo"
failures=0

run_and_capture() {
  set +e
  local output
  output=$("$@" 2>&1)
  local status=$?
  set -e
  printf '%s\n' "$status"
  printf '%s\n' "$output"
}

status_and_output=$(run_and_capture "$BIN")
status=$(printf '%s\n' "$status_and_output" | sed -n '1p')
output=$(printf '%s\n' "$status_and_output" | sed -n '2,$p')
if [ "$status" -eq 0 ]; then
  echo "❌ missing args should fail"
  failures=$((failures + 1))
else
  echo "✅ missing args fail"
fi
if ! grep -q "Error: invalid arguments" <<<"$output"; then
  echo "❌ missing args message wrong"
  failures=$((failures + 1))
else
  echo "✅ missing args message ok"
fi

status_and_output=$(run_and_capture "$BIN" 2 800 abc 200)
status=$(printf '%s\n' "$status_and_output" | sed -n '1p')
output=$(printf '%s\n' "$status_and_output" | sed -n '2,$p')
if [ "$status" -eq 0 ]; then
  echo "❌ non-numeric arg should fail"
  failures=$((failures + 1))
else
  echo "✅ non-numeric arg fail"
fi
if ! grep -q "Error: arguments must be positive integers" <<<"$output"; then
  echo "❌ non-numeric message wrong"
  failures=$((failures + 1))
else
  echo "✅ non-numeric message ok"
fi

status_and_output=$(run_and_capture "$BIN" 2 200 100 100 -1)
status=$(printf '%s\n' "$status_and_output" | sed -n '1p')
output=$(printf '%s\n' "$status_and_output" | sed -n '2,$p')
if [ "$status" -eq 0 ]; then
  echo "❌ invalid eat count should fail"
  failures=$((failures + 1))
else
  echo "✅ invalid eat count fail"
fi
if ! grep -q "Error: invalid eat count" <<<"$output"; then
  echo "❌ invalid eat count message wrong"
  failures=$((failures + 1))
else
  echo "✅ invalid eat count message ok"
fi

if command -v timeout >/dev/null 2>&1; then
  run_cmd=(timeout 2s "$BIN" 1 50 10 10)
else
  run_cmd=("$BIN" 1 50 10 10)
fi
status_and_output=$(run_and_capture "${run_cmd[@]}")
output=$(printf '%s\n' "$status_and_output" | sed -n '2,$p')
if ! grep -q "died" <<<"$output"; then
  echo "❌ single philosopher should die"
  failures=$((failures + 1))
else
  echo "✅ single philosopher died"
fi

echo
if [ "$failures" -eq 0 ]; then
  echo "All tests passed."
else
  echo "$failures test(s) failed."
  exit 1
fi
