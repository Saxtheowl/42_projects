# ft_ssl [md5] [sha256] [base64] [des]

An introduction to cryptographic hashing and encryption - implementing MD5, SHA-256, Base64, and DES.

## Description

This project recreates part of the OpenSSL functionality, specifically:
- MD5 and SHA-256 hashing algorithms
- Base64 encoding/decoding
- DES encryption (ECB and CBC modes)

It provides a command-line interface similar to `openssl`.

## Features

### Message Digest Commands
- **MD5**: Message Digest 5 (128-bit hash)
- **SHA-256**: Secure Hash Algorithm 256-bit

### Cipher Commands
- **Base64**: Base64 encoding/decoding
- **DES-ECB**: DES encryption in Electronic Codebook mode
- **DES-CBC**: DES encryption in Cipher Block Chaining mode

### Hash Flags

| Flag | Description |
|------|-------------|
| `-p` | Echo STDIN to STDOUT and append the checksum |
| `-q` | Quiet mode (only output the hash) |
| `-r` | Reverse the format of the output |
| `-s` | Print the hash of the given string |

### Cipher Flags

| Flag | Description |
|------|-------------|
| `-d` | Decrypt mode |
| `-e` | Encrypt mode (default) |
| `-a` | Base64 encode/decode |
| `-i` | Input file |
| `-o` | Output file |
| `-k` | Key in hex (DES) |
| `-v` | Initialization vector in hex (DES-CBC) |

## Compilation

```bash
make
```

## Usage

```bash
# Basic usage
./ft_ssl md5 file.txt
./ft_ssl sha256 file.txt

# Hash from stdin
echo "hello" | ./ft_ssl md5

# Hash a string
./ft_ssl md5 -s "hello world"

# Echo stdin and append hash
echo "test" | ./ft_ssl md5 -p

# Quiet mode
./ft_ssl sha256 -q file.txt

# Reversed output format
./ft_ssl md5 -r file.txt

# Combined flags
echo "data" | ./ft_ssl md5 -p -s "foo" file.txt
```

## Examples

```bash
$ echo "42 is nice" | ./ft_ssl md5
(stdin)= 35f1d6de0302e2086a4e472266efb3a9

$ echo "42 is nice" | ./ft_ssl md5 -p
("42 is nice")= 35f1d6de0302e2086a4e472266efb3a9

$ ./ft_ssl md5 -s "hello"
MD5 ("hello") = 5d41402abc4b2a76b9719d911017c592

$ echo "And above all," > file
$ ./ft_ssl md5 file
MD5 (file) = 53d53ea94217b259c11a5a2d104ec58a

$ ./ft_ssl md5 -r file
53d53ea94217b259c11a5a2d104ec58a file

$ ./ft_ssl sha256 -s "42 is nice"
SHA256 ("42 is nice") = b7e44c7a40c5f80139f0a50f3650fb2bd8d00b0d24667c4c2ca32c88e13b758f
```

## Base64 Examples

```bash
# Encode
echo -n "Hello World" | ./ft_ssl base64
# Output: SGVsbG8gV29ybGQ=

# Decode
echo "SGVsbG8gV29ybGQ=" | ./ft_ssl base64 -d
# Output: Hello World
```

## DES Examples

```bash
# DES-ECB encryption with base64 output
echo -n "Test1234" | ./ft_ssl des-ecb -a -k 0123456789ABCDEF

# DES-CBC encryption with IV
echo -n "Test1234" | ./ft_ssl des-cbc -k 0123456789ABCDEF -v 8877665544332211

# DES decryption
echo "encrypted" | ./ft_ssl des-ecb -d -a -k 0123456789ABCDEF
```

## Testing

Compare outputs with system tools:

```bash
# MD5
echo "test" | md5sum
echo "test" | ./ft_ssl md5

# SHA256
echo "test" | sha256sum
echo "test" | ./ft_ssl sha256

# Base64
echo -n "test" | base64
echo -n "test" | ./ft_ssl base64
```

## Implementation Details

### MD5 Algorithm
- 128-bit hash (16 bytes)
- Little-endian byte order
- Based on RFC 1321

### SHA-256 Algorithm
- 256-bit hash (32 bytes)
- Big-endian byte order
- Based on FIPS 180-4

### Base64
- Standard Base64 alphabet
- Proper padding with '='

### DES (Data Encryption Standard)
- 64-bit block cipher with 56-bit effective key
- PKCS7 padding
- ECB (Electronic Codebook) and CBC (Cipher Block Chaining) modes

## Allowed Functions

- `open`, `close`, `read`, `write`, `malloc`, `free`

## Author

Implementation for 42 curriculum.
