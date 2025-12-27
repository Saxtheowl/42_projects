#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

BIN="$ROOT/ft_ssl"
TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT

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

# md5 string
exp=$(printf "abc" | md5sum | awk '{print $1}')
act=$("$BIN" md5 -q -s "abc")
expect_eq "$exp" "$act" "md5 -s \"abc\""

# sha256 string
exp=$(printf "hello world" | sha256sum | awk '{print $1}')
act=$("$BIN" sha256 -q -s "hello world")
expect_eq "$exp" "$act" "sha256 -s \"hello world\""

# file hashing
echo "42 school" > "$TMP/file.txt"
exp=$(md5sum "$TMP/file.txt" | awk '{print $1}')
act=$("$BIN" md5 -q "$TMP/file.txt")
expect_eq "$exp" "$act" "md5 file.txt"

# stdin without -p
exp=$(printf "stdin test" | sha256sum | awk '{print $1}')
act=$(printf "stdin test" | "$BIN" sha256 -q)
expect_eq "$exp" "$act" "sha256 stdin"

# stdin with -p (echo then digest line)
input="forty-two"
out=$(printf "%s" "$input" | "$BIN" md5 -p)
echo_line=$(head -n 1 <<<"$out")
hash_line=$(tail -n 1 <<<"$out" | awk '{print $NF}')
exp=$(printf "%s" "$input" | md5sum | awk '{print $1}')
expect_eq "$input" "$echo_line" "md5 -p echoes stdin"
expect_eq "$exp" "$hash_line" "md5 -p hash"

# multiple -p (echo twice)
input="double-pass"
out=$(printf "%s" "$input" | "$BIN" sha256 -p -p)
first_echo=$(echo "$out" | sed -n '1p')
first_hash=$(echo "$out" | sed -n '2p' | awk '{print $NF}')
second_echo=$(echo "$out" | sed -n '3p')
second_hash=$(echo "$out" | sed -n '4p' | awk '{print $NF}')
exp=$(printf "%s" "$input" | sha256sum | awk '{print $1}')
expect_eq "$input" "$first_echo" "sha256 -p first echo"
expect_eq "$exp" "$first_hash" "sha256 -p first hash"
expect_eq "$input" "$second_echo" "sha256 -p second echo"
expect_eq "$exp" "$second_hash" "sha256 -p second hash"

# reverse + string quotes
exp=$(printf "foo" | md5sum | awk '{print $1}')
out=$("$BIN" md5 -r -s "foo")
expect_eq "$exp \"foo\"" "$out" "md5 -r -s quotes"

# multiple -s
out=$("$BIN" sha256 -q -s "a" -s "b")
exp1=$(printf "a" | sha256sum | awk '{print $1}')
exp2=$(printf "b" | sha256sum | awk '{print $1}')
line1=$(echo "$out" | sed -n '1p')
line2=$(echo "$out" | sed -n '2p')
expect_eq "$exp1" "$line1" "sha256 -q first -s"
expect_eq "$exp2" "$line2" "sha256 -q second -s"

# reverse file
echo "rev file" > "$TMP/rev.txt"
exp=$(md5sum "$TMP/rev.txt" | awk '{print $1}')
out=$("$BIN" md5 -r "$TMP/rev.txt")
expect_eq "$exp $TMP/rev.txt" "$out" "md5 -r file"

# missing file => error + non-zero (but continue)
if "$BIN" sha256 missing_file 2>/dev/null; then
    echo "❌ missing file should fail"
    failures=$((failures + 1))
else
    echo "✅ missing file fails as expected"
fi

# missing -s argument
if "$BIN" md5 -s; then
    echo "❌ -s without arg should fail"
    failures=$((failures + 1))
else
    echo "✅ -s without arg fails as expected"
fi

# unknown command
if "$BIN" unknown_cmd 2>/dev/null; then
    echo "❌ unknown command should fail"
    failures=$((failures + 1))
else
    echo "✅ unknown command fails as expected"
fi

# illegal option
if "$BIN" md5 -z 2>/dev/null; then
    echo "❌ illegal option should fail"
    failures=$((failures + 1))
else
    echo "✅ illegal option fails as expected"
fi

# -q file (hash only)
echo "quiet file" > "$TMP/q.txt"
exp=$(md5sum "$TMP/q.txt" | awk '{print $1}')
out=$("$BIN" md5 -q "$TMP/q.txt")
expect_eq "$exp" "$out" "-q with file prints hash only"

# -r with string
exp=$(printf "bar" | sha256sum | awk '{print $1}')
out=$("$BIN" sha256 -r -s "bar")
expect_eq "$exp \"bar\"" "$out" "-r with -s string formatting"

# missing file but next exists: exit non-zero but prints second hash
echo "ok" > "$TMP/ok.txt"
out=$("$BIN" md5 missing1 "$TMP/ok.txt" 2>/dev/null || true)
hash_line=$(echo "$out" | tail -n 1)
exp=$(md5sum "$TMP/ok.txt" | awk '{print $1}')
expect_eq "MD5 ($TMP/ok.txt) = $exp" "$hash_line" "continues hashing after missing file"

# -q with stdin via -p (echo + hash line only)
input="quiet-stdin"
out=$(printf "%s" "$input" | "$BIN" md5 -q -p)
lines=$(echo "$out" | wc -l)
hash_only=$(echo "$out" | sed -n '2p')
exp=$(printf "%s" "$input" | md5sum | awk '{print $1}')
if [[ "$lines" -ne 2 ]]; then
    echo "❌ -q -p should produce echo + hash only"
    failures=$((failures + 1))
else
    expect_eq "$exp" "$hash_only" "-q -p prints only hash after echo"
fi

# -s before file keeps order (quiet)
echo "order-file" > "$TMP/order.txt"
out=$("$BIN" sha256 -q -s "order" "$TMP/order.txt")
line1=$(echo "$out" | sed -n '1p')
line2=$(echo "$out" | sed -n '2p')
exp1=$(printf "order" | sha256sum | awk '{print $1}')
exp2=$(sha256sum "$TMP/order.txt" | awk '{print $1}')
expect_eq "$exp1" "$line1" "-s before file first"
expect_eq "$exp2" "$line2" "file after -s second"

# -q -r with file = hash only
out=$("$BIN" md5 -q -r "$TMP/order.txt")
exp=$(md5sum "$TMP/order.txt" | awk '{print $1}')
expect_eq "$exp" "$out" "-q -r with file prints hash only"

echo
if [[ $failures -eq 0 ]]; then
    echo "All tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
