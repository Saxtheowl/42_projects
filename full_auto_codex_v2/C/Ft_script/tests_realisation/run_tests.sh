#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

BIN="$ROOT/ft_script"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

failures=0

expect_status() {
    local expected="$1"
    shift
    if "$@"; then
        rc=0
    else
        rc=$?
    fi
    if [[ $rc -eq $expected ]]; then
        echo "✅ status $expected OK for $*"
    else
        echo "❌ status mismatch for $*: expected $expected got $rc"
        failures=$((failures + 1))
    fi
}

expect_contains() {
    local needle="$1"
    local file="$2"
    local label="$3"
    if grep -q "$needle" "$file"; then
        echo "✅ $label"
    else
        echo "❌ $label"
        failures=$((failures + 1))
    fi
}

# Default output file
printf "echo hello_world\nexit\n" | "$BIN" -q >/dev/null
if [[ ! -f typescript ]]; then
    echo "❌ default output file missing"
    failures=$((failures + 1))
else
    expect_contains "hello_world" "typescript" "default session captured"
    rm -f typescript
fi

# Custom output file
out="$TMP/session.log"
printf "echo custom\nexit\n" | "$BIN" -q "$out" >/dev/null
if [[ ! -f "$out" ]]; then
    echo "❌ custom output file missing"
    failures=$((failures + 1))
else
    expect_contains "custom" "$out" "custom session captured"
fi

# -c option
cmd_out="$TMP/cmd.log"
"$BIN" -q -c "echo from_cmd" "$cmd_out" >/dev/null
expect_contains "from_cmd" "$cmd_out" "-c command captured"

# -f flushes immediately (check after first command before exit)
flush_log="$TMP/flush.log"
(
    printf "echo first_flush\nsleep 1\necho done\nexit\n" | "$BIN" -f -q "$flush_log" >/dev/null
) &
sleep 0.4
if grep -q "first_flush" "$flush_log"; then
    echo "✅ flush writes immediately"
else
    echo "❌ flush missing early data"
    failures=$((failures + 1))
fi
wait

# append option
app="$TMP/app.log"
"$BIN" -q -c "echo first" -a "$app" >/dev/null
"$BIN" -q -c "echo second" -a "$app" >/dev/null
count=$(grep -c '^first$' "$app")
count2=$(grep -c '^second$' "$app")
if [[ "$count" -eq 1 && "$count2" -eq 1 ]]; then
    echo "✅ append preserves previous content"
else
    echo "❌ append failed"
    failures=$((failures + 1))
fi

# quiet option (no banners on stdout, only command output)
out_quiet=$("$BIN" -q -c "echo quiet_check" "$TMP/quiet.log")
if [[ "$out_quiet" == "quiet_check" || "$out_quiet" == $'quiet_check\n' ]]; then
    echo "✅ quiet option suppresses banners"
else
    echo "❌ quiet option produced unexpected stdout"
    failures=$((failures + 1))
fi
expect_contains "quiet_check" "$TMP/quiet.log" "quiet log captured"

# -e returns child status
expect_status 0 "$BIN" -q -c "exit 7" >/dev/null
expect_status 7 "$BIN" -q -e -c "exit 7" >/dev/null

echo
if [[ $failures -eq 0 ]]; then
    echo "All tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
