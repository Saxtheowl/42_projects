# libasm

Introduction to x86_64 assembly language programming on Linux.

## Description

This project implements basic C library functions in x86_64 assembly language using the AT&T syntax.

## Functions Implemented

| Function | Description |
|----------|-------------|
| `ft_strlen` | Calculate string length |
| `ft_strcpy` | Copy string |
| `ft_strcmp` | Compare strings |
| `ft_write` | Write to file descriptor (syscall wrapper) |
| `ft_read` | Read from file descriptor (syscall wrapper) |
| `ft_strdup` | Duplicate string |

## Compilation

```bash
make        # Build library
make test   # Build and run tests
make clean  # Remove object files
make fclean # Remove all generated files
```

## Usage

```c
#include "libasm.h"

int main(void)
{
    // ft_strlen
    size_t len = ft_strlen("Hello");  // returns 5
    
    // ft_strcpy
    char buffer[10];
    ft_strcpy(buffer, "Hi");
    
    // ft_strcmp
    int cmp = ft_strcmp("abc", "abd");  // returns -1
    
    // ft_write
    ft_write(1, "Hello\n", 6);  // write to stdout
    
    // ft_read
    char buf[100];
    ssize_t n = ft_read(0, buf, 100);  // read from stdin
    
    // ft_strdup
    char *dup = ft_strdup("Hello");
    free(dup);
    
    return 0;
}
```

## Linking

```bash
cc -Wall -Wextra -Werror main.c -L. -lasm -o program
```

## Technical Details

### Calling Convention (System V AMD64 ABI)
- Arguments: rdi, rsi, rdx, rcx, r8, r9
- Return value: rax
- Callee-saved: rbx, rbp, r12-r15
- Caller-saved: rax, rcx, rdx, rsi, rdi, r8-r11

### System Calls
- write: syscall number 1
- read: syscall number 0
- Error handling via errno (using __errno_location)

## Files

| File | Description |
|------|-------------|
| `src/ft_strlen.s` | String length function |
| `src/ft_strcpy.s` | String copy function |
| `src/ft_strcmp.s` | String compare function |
| `src/ft_write.s` | Write syscall wrapper |
| `src/ft_read.s` | Read syscall wrapper |
| `src/ft_strdup.s` | String duplicate function |
| `libasm.h` | Header file |
| `main.c` | Test program |
| `Makefile` | Build configuration |

## Author

Implementation for 42 curriculum.
