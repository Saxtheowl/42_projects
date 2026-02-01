# Rainfall - Security CTF

Binary exploitation challenge series.

## Note

This project requires specific binary files and a VM environment.
Below are the concepts and techniques covered.

## Levels Overview

### Level 0
- Basic binary execution
- Find password in binary

### Level 1
- Buffer overflow introduction
- Stack smashing basics

### Level 2
- Return-to-libc
- ret2libc technique

### Level 3
- Format string vulnerability
- Reading stack values

### Level 4
- Format string write
- Arbitrary write primitive

### Level 5
- GOT overwrite
- Global Offset Table manipulation

### Level 6
- Heap exploitation
- Malloc/free vulnerabilities

### Level 7
- Advanced heap
- Unlink exploitation

### Level 8
- Environment variables
- PATH hijacking

### Level 9
- Integer overflow
- Signed/unsigned issues

## Techniques Covered

### Buffer Overflow
```c
void vulnerable(char *input) {
    char buffer[64];
    strcpy(buffer, input);  // No bounds checking
}
```

### Format String
```c
printf(user_input);  // Should be printf("%s", user_input);
```

### Return to libc
```
[buffer][padding][system()][exit()]["/bin/sh"]
```

### GOT Overwrite
Replace function pointer in GOT with shellcode address.

## Tools

- GDB
- objdump
- ltrace/strace
- Python for exploit scripts
- pwntools

## Exploitation Steps

1. Analyze binary (file, checksec)
2. Find vulnerability (GDB, ltrace)
3. Determine offsets
4. Craft payload
5. Execute exploit

## Protection Mechanisms

| Protection | Description |
|------------|-------------|
| ASLR | Address randomization |
| NX | Non-executable stack |
| Canary | Stack protector |
| PIE | Position independent |
| RELRO | Relocation read-only |

## Resources

- "Hacking: The Art of Exploitation"
- Phrack articles
- Exploit-DB
- CTF writeups

## Author

Challenge guide for 42 curriculum (security track).
