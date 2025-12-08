#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BIN="$ROOT/ft_turing"
if [ ! -x "$BIN" ]; then
  echo "Build first with make" >&2
  exit 1
fi

pass=0; total=0

test_case() {
  local cmd="$1" expected="$2"
  total=$((total+1))
  echo "-- $cmd"
  output=$(eval "$cmd" 2>&1 || true)
  if [ "$output" = "$expected" ]; then
    echo "OK: $output"
    pass=$((pass+1))
  else
    echo "FAIL: expected '$expected' got '$output'" >&2
  fi
}

test_case "$BIN $ROOT/examples/unary_increment.tm aaaa -t" "ACCEPT after 10 steps (state=qacc)
Final tape: _aaaaa"
tmp_tape=$(mktemp)
test_case "$BIN $ROOT/examples/unary_increment.tm aaaa -o $tmp_tape" "ACCEPT after 10 steps (state=qacc)"
if [ "$(cat "$tmp_tape")" != "_aaaaa" ]; then echo "FAIL: expected tape written to file" >&2; exit 1; fi
rm -f "$tmp_tape"
test_case "$BIN $ROOT/examples/reject_even.tm aa" "REJECT after 3 steps (state=qrej)"
test_case "$BIN $ROOT/examples/reject_even.tm aaa" "ACCEPT after 4 steps (state=qacc)"
test_case "$BIN $ROOT/examples/loop.tm aaaa -s 5" "REJECT after 5 steps (state=q0)"
test_case "$BIN $ROOT/examples/bad_input.tm a" "Error: Transition reads symbol not in alphabet: b"
test_case "$BIN $ROOT/examples/invalid_duplicate.tm a" "Error: Line 9: duplicate transition for state q0 and symbol a"
test_case "$BIN $ROOT/examples/invalid_move.tm a" "Error: Transition move must be L or R"
test_case "$BIN $ROOT/examples/invalid_unknown_state.tm a" "Error: Transition targets unknown state: q2"
test_case "$BIN $ROOT/examples/invalid_missing_blank.tm a" "Error: Blank symbol not specified"
test_case "$BIN $ROOT/examples/invalid_blank_not_in_alphabet.tm a" "Error: Blank symbol '_' not in alphabet"
test_case "$BIN $ROOT/examples/invalid_missing_states.tm a" "Error: No states defined"
test_case "$BIN $ROOT/examples/invalid_missing_alphabet.tm a" "Error: No alphabet defined"
test_case "$BIN $ROOT/examples/invalid_missing_initial.tm a" "Error: No initial state defined"
test_case "$BIN $ROOT/examples/invalid_transition_extra_tokens.tm a" "Error: Line 8: extra tokens after transition"
test_case "$BIN $ROOT/examples/invalid_missing_transition.tm a -c" "Error: Missing transition for state q0 and symbol _"
test_case "$BIN $ROOT/examples/invalid_missing_transition.tm _ -r" "REJECT after 0 steps (state=q0)
[reason] no transition for state q0 and symbol _"
test_case "$BIN $ROOT/examples/loop.tm aaaa -s 2 -r" "REJECT after 2 steps (state=q0)
[reason] max steps reached"

echo "$pass/$total tests passed"
[ $pass -eq $total ]
