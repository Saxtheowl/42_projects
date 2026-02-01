# woody_woodpacker - ELF Binary Packer

Simple ELF binary packer with XOR encryption.

## Features

- ELF64 binary parsing
- .text section identification
- XOR encryption
- Packed binary generation

## Usage

```bash
./woody_woodpacker <binary>
```

Output is saved as `woody`.

## Building

```bash
make
```

## How It Works

1. Load ELF binary into memory
2. Validate ELF format (64-bit executable)
3. Find .text section
4. Encrypt .text with XOR cipher
5. Save packed binary

## Output Information

- ELF type (EXEC/DYN)
- Entry point address
- .text section offset and size
- Encryption key used

## Note

This is an educational implementation. A real packer would:
- Insert decryption stub code
- Modify entry point to decryptor
- Handle segment alignment
- Support various encryption methods

## Author

Implementation for 42 curriculum.
