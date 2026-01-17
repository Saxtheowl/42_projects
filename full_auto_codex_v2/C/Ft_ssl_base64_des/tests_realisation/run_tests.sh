#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

make >/dev/null

BIN="$ROOT/ft_ssl_base64_des"
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

# encode string vs openssl
exp=$(printf "hello" | openssl base64 | tr -d '\n')
act=$(printf "hello" | $BIN base64 -e | tr -d '\n')
expect_eq "$exp" "$act" "encode matches openssl"

# encode empty input
exp=$(printf "" | openssl base64 | tr -d '\n')
act=$(printf "" | $BIN base64 -e | tr -d '\n')
expect_eq "$exp" "$act" "encode empty input"

# decode string vs openssl (-A to accept single-line input)
b64=$(printf "42 school" | openssl base64)
exp=$(printf "%s" "$b64" | openssl base64 -d -A)
act=$(printf "%s" "$b64" | $BIN base64 -d)
expect_eq "$exp" "$act" "decode matches openssl"

# file encode/decode roundtrip
head -c 200 /dev/urandom > "$TMP/random.bin"
$BIN base64 -e -i "$TMP/random.bin" -o "$TMP/random.b64"
$BIN base64 -d -i "$TMP/random.b64" -o "$TMP/random.out"
expect_eq "$(sha256sum "$TMP/random.bin" | awk '{print $1}')" "$(sha256sum "$TMP/random.out" | awk '{print $1}')" "roundtrip sha256 match"

# DES ECB roundtrip
key="133457799BBCDFF1"
printf "ECB test data 123" > "$TMP/plain.txt"
$BIN des-ecb -e -k "$key" -i "$TMP/plain.txt" -o "$TMP/enc_ecb.bin"
$BIN des-ecb -d -k "$key" -i "$TMP/enc_ecb.bin" -o "$TMP/dec_ecb.txt"
expect_eq "$(sha256sum "$TMP/plain.txt" | awk '{print $1}')" "$(sha256sum "$TMP/dec_ecb.txt" | awk '{print $1}')" "DES ECB roundtrip"

# DES CBC roundtrip
iv="0102030405060708"
$BIN des-cbc -e -k "$key" -v "$iv" -i "$TMP/plain.txt" -o "$TMP/enc_cbc.bin"
$BIN des-cbc -d -k "$key" -v "$iv" -i "$TMP/enc_cbc.bin" -o "$TMP/dec_cbc.txt"
expect_eq "$(sha256sum "$TMP/plain.txt" | awk '{print $1}')" "$(sha256sum "$TMP/dec_cbc.txt" | awk '{print $1}')" "DES CBC roundtrip"

# DES CBC with password+salt derivation (MD5 EVP_BytesToKey)
pass="mypass"
salt="0001020304050607"
$BIN des-cbc -e -p "$pass" -s "$salt" -i "$TMP/plain.txt" -o "$TMP/enc_pass.bin"
$BIN des-cbc -d -p "$pass" -s "$salt" -i "$TMP/enc_pass.bin" -o "$TMP/dec_pass.txt"
expect_eq "$(sha256sum "$TMP/plain.txt" | awk '{print $1}')" "$(sha256sum "$TMP/dec_pass.txt" | awk '{print $1}')" "DES CBC pass+salt roundtrip"

# DES CBC pass+salt with -a and salted header autodetected
out_b64=$($BIN des-cbc -e -p "$pass" -s "$salt" -a -i "$TMP/plain.txt")
decoded=$($BIN des-cbc -d -p "$pass" -a <<<"$out_b64")
expect_eq "$(cat "$TMP/plain.txt")" "$decoded" "DES CBC -a salted autodetect"

# Salted header without password must fail
if $BIN des-cbc -d -a <<<"$out_b64" >/dev/null 2>&1; then
    echo "❌ salted header without password should fail"
    failures=$((failures + 1))
else
    echo "✅ salted header without password fails as expected"
fi

# Wrong password must fail
if $BIN des-cbc -d -p "wrongpass" -a <<<"$out_b64" >/dev/null 2>&1; then
    echo "❌ wrong password should fail"
    failures=$((failures + 1))
else
    echo "✅ wrong password fails as expected"
fi

# DES ECB with -a roundtrip (self)
our_out=$(printf "Base64 ECB" | $BIN des-ecb -e -k "$key" -a | tr -d '\n')
back=$(printf "%s" "$our_out" | $BIN des-ecb -d -k "$key" -a)
expect_eq "Base64 ECB" "$back" "DES ECB -a self roundtrip"

# DES CBC with -a roundtrip (self)
our_out=$(printf "Base64 CBC" | $BIN des-cbc -e -k "$key" -v "$iv" -a | tr -d '\n')
back=$(printf "%s" "$our_out" | $BIN des-cbc -d -k "$key" -v "$iv" -a)
expect_eq "Base64 CBC" "$back" "DES CBC -a self roundtrip"

# base64 wrapping at 64 cols
long_plain=$(printf 'A%.0s' {1..80})
wrapped=$($BIN base64 -e <<<"$long_plain")
maxlen=$(echo "$wrapped" | awk '{if(length($0)>m)m=length($0)} END{print m}')
expect_eq "64" "$maxlen" "base64 wrap 64 cols"
wrapped_des=$($BIN des-ecb -e -k "$key" -a <<<"$long_plain")
maxlen_des=$(echo "$wrapped_des" | awk '{if(length($0)>m)m=length($0)} END{print m}')
expect_eq "64" "$maxlen_des" "des -a wrap 64 cols"

# -A disables wrapping (no trailing newline)
printf "foo" | $BIN base64 -A > "$TMP/b64_nowrap"
expect_eq "5A6D3976" "$(hexdump -v -e '1/1 "%02X"' "$TMP/b64_nowrap")" "base64 -A no wrap"
printf "no wrap" | $BIN des-ecb -e -k "$key" -a -A > "$TMP/des_nowrap"
hex_nowrap=$(hexdump -v -e '1/1 "%02X"' "$TMP/des_nowrap")
if [[ "$hex_nowrap" == *"0A" ]]; then
    echo "❌ des -a -A should not append newline"
    failures=$((failures + 1))
else
    echo "✅ des -a -A no newline"
fi

echo
if [[ $failures -eq 0 ]]; then
    echo "All tests passed."
else
    echo "$failures test(s) failed."
    exit 1
fi
