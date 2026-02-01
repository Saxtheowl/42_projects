# ft_printf

## Description

ft_printf is a re-implementation of the standard C library function `printf()`. This project teaches the use of variadic functions in C.

## Supported Conversions

| Specifier | Description |
|-----------|-------------|
| `%c` | Print a single character |
| `%s` | Print a string |
| `%p` | Print a pointer address in hexadecimal |
| `%d` | Print a decimal (base 10) number |
| `%i` | Print an integer in base 10 |
| `%u` | Print an unsigned decimal number |
| `%x` | Print a number in hexadecimal (lowercase) |
| `%X` | Print a number in hexadecimal (uppercase) |
| `%%` | Print a percent sign |

## Compilation

```bash
# Compile the library
make

# Clean object files
make clean

# Full clean (including library)
make fclean

# Recompile
make re
```

## Usage

```c
#include "ft_printf.h"

int main(void)
{
    ft_printf("Hello, %s!\n", "World");
    ft_printf("Number: %d\n", 42);
    ft_printf("Hex: %x\n", 255);
    ft_printf("Pointer: %p\n", &main);
    return (0);
}
```

Compile with:
```bash
cc -Wall -Wextra -Werror main.c libftprintf.a -o program
```

## Return Value

Returns the number of characters printed (excluding the null byte), or -1 on error.

## Author

Implementation for 42 curriculum.
