# libftasm2 - Extended Assembly Library

Additional assembly functions extending libftasm, implementing memory and string operations in x86-64 assembly.

## Features

### Memory Functions
- `ft_memset` - Fill memory with byte
- `ft_memcpy` - Copy memory area
- `ft_memmove` - Copy memory with overlap handling
- `ft_memcmp` - Compare memory areas
- `ft_memchr` - Search for byte in memory
- `ft_bzero` - Zero memory area

### String Functions
- `ft_strnlen` - Length with limit
- `ft_strncpy` - Copy with limit
- `ft_strncmp` - Compare with limit
- `ft_strchr` - Find character
- `ft_strrchr` - Find last character

### Character Functions
- `ft_toupper` - Convert to uppercase
- `ft_tolower` - Convert to lowercase
- `ft_isprint` - Check printable
- `ft_isspace` - Check whitespace

### Utility Functions
- `ft_abs` - Absolute value
- `ft_swap` - Swap two integers
- `ft_atoi` - String to integer

## Building

```bash
make        # Build library
make test   # Build and run tests
```

## Requirements

- NASM assembler
- x86-64 architecture
- Linux/Unix (System V AMD64 ABI)

## Calling Convention

All functions follow the System V AMD64 ABI:
- Arguments: rdi, rsi, rdx, rcx, r8, r9
- Return value: rax
- Caller-saved: rax, rcx, rdx, rsi, rdi, r8, r9, r10, r11
- Callee-saved: rbx, rbp, r12-r15

## Usage

```c
#include <stddef.h>

// Declare functions
void *ft_memset(void *s, int c, size_t n);
void *ft_memcpy(void *dest, const void *src, size_t n);
int ft_memcmp(const void *s1, const void *s2, size_t n);
int ft_atoi(const char *str);
int ft_abs(int n);

int main(void)
{
    char buffer[100];

    ft_memset(buffer, 0, 100);
    ft_memcpy(buffer, "Hello", 5);

    int num = ft_atoi("-42");
    int abs_num = ft_abs(num);

    return 0;
}
```

## Assembly Techniques

- Uses `rep` prefix for efficient memory operations
- Direction flag handling for memmove
- Conditional moves where applicable
- Sign extension with `cdq` for abs

## Author

Implementation for 42 curriculum.
