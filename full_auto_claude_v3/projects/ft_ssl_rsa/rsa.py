#!/usr/bin/env python3
"""
ft_ssl RSA - RSA encryption/decryption implementation
Generates keys, encrypts and decrypts messages
"""

import sys
import os
import math
import json
import base64
from typing import Tuple, Optional
import random


def is_prime_miller_rabin(n: int, k: int = 40) -> bool:
    """Miller-Rabin primality test."""
    if n < 2:
        return False
    if n == 2 or n == 3:
        return True
    if n % 2 == 0:
        return False

    # Write n-1 as 2^r * d
    r, d = 0, n - 1
    while d % 2 == 0:
        r += 1
        d //= 2

    # Witness loop
    for _ in range(k):
        a = random.randrange(2, n - 1)
        x = pow(a, d, n)

        if x == 1 or x == n - 1:
            continue

        for _ in range(r - 1):
            x = pow(x, 2, n)
            if x == n - 1:
                break
        else:
            return False

    return True


def generate_prime(bits: int) -> int:
    """Generate a random prime number of specified bit length."""
    while True:
        # Generate random odd number
        n = random.getrandbits(bits)
        n |= (1 << bits - 1) | 1  # Set MSB and LSB

        if is_prime_miller_rabin(n):
            return n


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm."""
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = extended_gcd(b % a, a)
    x = y1 - (b // a) * x1
    y = x1
    return gcd, x, y


def mod_inverse(e: int, phi: int) -> int:
    """Compute modular multiplicative inverse."""
    gcd, x, _ = extended_gcd(e, phi)
    if gcd != 1:
        raise ValueError("Modular inverse doesn't exist")
    return x % phi


def gcd(a: int, b: int) -> int:
    """Compute GCD."""
    while b:
        a, b = b, a % b
    return a


class RSAKey:
    """RSA key pair."""

    def __init__(self, bits: int = 2048):
        self.bits = bits
        self.n: Optional[int] = None  # Modulus
        self.e: Optional[int] = None  # Public exponent
        self.d: Optional[int] = None  # Private exponent
        self.p: Optional[int] = None  # Prime 1
        self.q: Optional[int] = None  # Prime 2

    def generate(self):
        """Generate RSA key pair."""
        print(f"Generating {self.bits}-bit RSA key pair...")

        # Generate two large primes
        print("  Generating prime p...")
        self.p = generate_prime(self.bits // 2)
        print("  Generating prime q...")
        self.q = generate_prime(self.bits // 2)

        # Compute modulus
        self.n = self.p * self.q

        # Compute Euler's totient
        phi = (self.p - 1) * (self.q - 1)

        # Choose public exponent (commonly 65537)
        self.e = 65537
        while gcd(self.e, phi) != 1:
            self.e += 2

        # Compute private exponent
        self.d = mod_inverse(self.e, phi)

        print("  Key generation complete.")

    def encrypt(self, message: int) -> int:
        """Encrypt a message (as integer)."""
        if message >= self.n:
            raise ValueError("Message too large for key size")
        return pow(message, self.e, self.n)

    def decrypt(self, ciphertext: int) -> int:
        """Decrypt a ciphertext (as integer)."""
        return pow(ciphertext, self.d, self.n)

    def sign(self, message: int) -> int:
        """Sign a message (encrypt with private key)."""
        return pow(message, self.d, self.n)

    def verify(self, signature: int) -> int:
        """Verify a signature (decrypt with public key)."""
        return pow(signature, self.e, self.n)

    def save_public(self, filename: str):
        """Save public key to file."""
        key_data = {
            'type': 'RSA PUBLIC KEY',
            'n': hex(self.n),
            'e': hex(self.e),
            'bits': self.bits
        }
        with open(filename, 'w') as f:
            f.write("-----BEGIN RSA PUBLIC KEY-----\n")
            json.dump(key_data, f, indent=2)
            f.write("\n-----END RSA PUBLIC KEY-----\n")
        print(f"Public key saved to {filename}")

    def save_private(self, filename: str):
        """Save private key to file."""
        key_data = {
            'type': 'RSA PRIVATE KEY',
            'n': hex(self.n),
            'e': hex(self.e),
            'd': hex(self.d),
            'p': hex(self.p),
            'q': hex(self.q),
            'bits': self.bits
        }
        with open(filename, 'w') as f:
            f.write("-----BEGIN RSA PRIVATE KEY-----\n")
            json.dump(key_data, f, indent=2)
            f.write("\n-----END RSA PRIVATE KEY-----\n")
        print(f"Private key saved to {filename}")

    def load_public(self, filename: str):
        """Load public key from file."""
        with open(filename, 'r') as f:
            content = f.read()

        # Extract JSON
        start = content.find('{')
        end = content.rfind('}') + 1
        key_data = json.loads(content[start:end])

        self.n = int(key_data['n'], 16)
        self.e = int(key_data['e'], 16)
        self.bits = key_data.get('bits', 2048)

    def load_private(self, filename: str):
        """Load private key from file."""
        with open(filename, 'r') as f:
            content = f.read()

        start = content.find('{')
        end = content.rfind('}') + 1
        key_data = json.loads(content[start:end])

        self.n = int(key_data['n'], 16)
        self.e = int(key_data['e'], 16)
        self.d = int(key_data['d'], 16)
        self.p = int(key_data.get('p', '0x0'), 16)
        self.q = int(key_data.get('q', '0x0'), 16)
        self.bits = key_data.get('bits', 2048)


def bytes_to_int(data: bytes) -> int:
    """Convert bytes to integer."""
    return int.from_bytes(data, byteorder='big')


def int_to_bytes(n: int, length: int = None) -> bytes:
    """Convert integer to bytes."""
    if length is None:
        length = (n.bit_length() + 7) // 8
    return n.to_bytes(length, byteorder='big')


def pkcs1_pad(message: bytes, key_size: int) -> bytes:
    """PKCS#1 v1.5 padding for encryption."""
    max_msg_len = key_size - 11
    if len(message) > max_msg_len:
        raise ValueError(f"Message too long: {len(message)} > {max_msg_len}")

    padding_len = key_size - len(message) - 3
    # Generate random non-zero padding bytes
    padding = bytes(random.randint(1, 255) for _ in range(padding_len))

    return b'\x00\x02' + padding + b'\x00' + message


def pkcs1_unpad(padded: bytes) -> bytes:
    """Remove PKCS#1 v1.5 padding."""
    if len(padded) < 11:
        raise ValueError("Invalid padding")
    if padded[0:2] != b'\x00\x02':
        raise ValueError("Invalid padding marker")

    # Find the zero separator
    sep_idx = padded.find(b'\x00', 2)
    if sep_idx < 10:  # At least 8 bytes of padding
        raise ValueError("Invalid padding")

    return padded[sep_idx + 1:]


def encrypt_message(message: str, key: RSAKey) -> str:
    """Encrypt a text message."""
    key_bytes = key.bits // 8
    msg_bytes = message.encode('utf-8')

    # Pad and encrypt
    padded = pkcs1_pad(msg_bytes, key_bytes)
    plaintext_int = bytes_to_int(padded)
    ciphertext_int = key.encrypt(plaintext_int)

    # Encode as base64
    ciphertext_bytes = int_to_bytes(ciphertext_int, key_bytes)
    return base64.b64encode(ciphertext_bytes).decode('ascii')


def decrypt_message(ciphertext_b64: str, key: RSAKey) -> str:
    """Decrypt a text message."""
    key_bytes = key.bits // 8

    # Decode from base64
    ciphertext_bytes = base64.b64decode(ciphertext_b64)
    ciphertext_int = bytes_to_int(ciphertext_bytes)

    # Decrypt and unpad
    plaintext_int = key.decrypt(ciphertext_int)
    padded = int_to_bytes(plaintext_int, key_bytes)
    msg_bytes = pkcs1_unpad(padded)

    return msg_bytes.decode('utf-8')


def run_demo():
    """Run RSA demo."""
    print("=" * 50)
    print("RSA Encryption Demo")
    print("=" * 50)

    # Generate keys (smaller size for demo speed)
    key = RSAKey(bits=1024)
    key.generate()

    print(f"\nPublic key (n, e):")
    print(f"  n = {hex(key.n)[:50]}...")
    print(f"  e = {key.e}")

    print(f"\nPrivate key (d):")
    print(f"  d = {hex(key.d)[:50]}...")

    # Save keys
    key.save_public('rsa_public.key')
    key.save_private('rsa_private.key')

    # Encrypt/decrypt test
    print("\n" + "=" * 50)
    print("Encryption Test")
    print("=" * 50)

    message = "Hello, RSA!"
    print(f"\nOriginal message: {message}")

    ciphertext = encrypt_message(message, key)
    print(f"Encrypted (base64): {ciphertext[:60]}...")

    decrypted = decrypt_message(ciphertext, key)
    print(f"Decrypted: {decrypted}")

    # Verify
    if decrypted == message:
        print("\nEncryption/decryption successful!")
    else:
        print("\nERROR: Decryption failed!")

    # Digital signature test
    print("\n" + "=" * 50)
    print("Digital Signature Test")
    print("=" * 50)

    # Simple hash (just sum of bytes for demo)
    msg_hash = sum(message.encode()) % key.n
    print(f"\nMessage hash: {msg_hash}")

    signature = key.sign(msg_hash)
    print(f"Signature: {hex(signature)[:50]}...")

    verified_hash = key.verify(signature)
    print(f"Verified hash: {verified_hash}")

    if verified_hash == msg_hash:
        print("\nSignature verification successful!")
    else:
        print("\nERROR: Signature verification failed!")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("ft_ssl RSA - RSA Encryption Tool")
        print("\nUsage:")
        print("  python rsa.py genkey [bits]           - Generate key pair")
        print("  python rsa.py encrypt <pubkey> <msg>  - Encrypt message")
        print("  python rsa.py decrypt <privkey> <enc> - Decrypt message")
        print("  python rsa.py demo                    - Run demo")
        return

    cmd = sys.argv[1]

    if cmd == 'demo':
        run_demo()

    elif cmd == 'genkey':
        bits = int(sys.argv[2]) if len(sys.argv) > 2 else 2048
        key = RSAKey(bits=bits)
        key.generate()
        key.save_public('rsa_public.key')
        key.save_private('rsa_private.key')

    elif cmd == 'encrypt':
        if len(sys.argv) < 4:
            print("Usage: python rsa.py encrypt <pubkey> <message>")
            return

        key = RSAKey()
        key.load_public(sys.argv[2])
        message = sys.argv[3]

        ciphertext = encrypt_message(message, key)
        print(ciphertext)

    elif cmd == 'decrypt':
        if len(sys.argv) < 4:
            print("Usage: python rsa.py decrypt <privkey> <ciphertext>")
            return

        key = RSAKey()
        key.load_private(sys.argv[2])
        ciphertext = sys.argv[3]

        plaintext = decrypt_message(ciphertext, key)
        print(plaintext)

    else:
        print(f"Unknown command: {cmd}")


if __name__ == "__main__":
    main()
