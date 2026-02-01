# ft_ssl RSA - RSA Encryption

RSA public-key cryptography implementation.

## Features

- Key generation (configurable bit size)
- PKCS#1 v1.5 padding
- Message encryption/decryption
- Digital signatures
- Base64 encoding for ciphertext
- Miller-Rabin primality testing

## Usage

```bash
# Generate 2048-bit key pair
python rsa.py genkey 2048

# Encrypt message
python rsa.py encrypt rsa_public.key "Hello World"

# Decrypt message
python rsa.py decrypt rsa_private.key <ciphertext>

# Run demo
python rsa.py demo
```

## Algorithm

1. **Key Generation**
   - Generate two large primes p, q
   - Compute n = p * q (modulus)
   - Compute φ(n) = (p-1)(q-1) (Euler's totient)
   - Choose e = 65537 (public exponent)
   - Compute d = e^(-1) mod φ(n) (private exponent)

2. **Encryption**: c = m^e mod n
3. **Decryption**: m = c^d mod n
4. **Signing**: s = m^d mod n
5. **Verification**: m = s^e mod n

## Key Files

- `rsa_public.key` - Contains (n, e)
- `rsa_private.key` - Contains (n, e, d, p, q)

## Security Notes

- Uses Miller-Rabin primality test (40 rounds)
- PKCS#1 v1.5 padding for message security
- Extended Euclidean algorithm for modular inverse

## Author

Implementation for 42 curriculum.
