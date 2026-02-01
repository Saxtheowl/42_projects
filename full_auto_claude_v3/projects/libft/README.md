# Libft - Your First Own Library

## Description

Libft is the first project of the 42 curriculum. It consists of re-implementing a set of standard C library functions, as well as additional useful functions for future projects.

## Contents

### Part 1 - Libc Functions
Re-implementations of standard C library functions:

| Function | Description |
|----------|-------------|
| `ft_isalpha` | Check if character is alphabetic |
| `ft_isdigit` | Check if character is a digit |
| `ft_isalnum` | Check if character is alphanumeric |
| `ft_isascii` | Check if character is ASCII |
| `ft_isprint` | Check if character is printable |
| `ft_strlen` | Get string length |
| `ft_memset` | Fill memory with a constant byte |
| `ft_bzero` | Zero a byte string |
| `ft_memcpy` | Copy memory area |
| `ft_memmove` | Copy memory area (handles overlap) |
| `ft_strlcpy` | Size-bounded string copy |
| `ft_strlcat` | Size-bounded string concatenation |
| `ft_toupper` | Convert to uppercase |
| `ft_tolower` | Convert to lowercase |
| `ft_strchr` | Locate character in string |
| `ft_strrchr` | Locate character from end |
| `ft_strncmp` | Compare strings |
| `ft_memchr` | Scan memory for character |
| `ft_memcmp` | Compare memory areas |
| `ft_strnstr` | Locate substring |
| `ft_atoi` | Convert string to integer |
| `ft_calloc` | Allocate and zero memory |
| `ft_strdup` | Duplicate string |

### Part 2 - Additional Functions

| Function | Description |
|----------|-------------|
| `ft_substr` | Extract substring |
| `ft_strjoin` | Concatenate strings |
| `ft_strtrim` | Trim characters from string |
| `ft_split` | Split string by delimiter |
| `ft_itoa` | Convert integer to string |
| `ft_strmapi` | Apply function to string (new string) |
| `ft_striteri` | Apply function to string (in place) |
| `ft_putchar_fd` | Output char to file descriptor |
| `ft_putstr_fd` | Output string to file descriptor |
| `ft_putendl_fd` | Output string with newline |
| `ft_putnbr_fd` | Output number to file descriptor |

### Bonus - Linked List Functions

| Function | Description |
|----------|-------------|
| `ft_lstnew` | Create new list element |
| `ft_lstadd_front` | Add element at beginning |
| `ft_lstsize` | Count list elements |
| `ft_lstlast` | Get last element |
| `ft_lstadd_back` | Add element at end |
| `ft_lstdelone` | Delete one element |
| `ft_lstclear` | Delete entire list |
| `ft_lstiter` | Iterate and apply function |
| `ft_lstmap` | Map function to list |

## Compilation

```bash
# Compile the library
make

# Compile with bonus functions
make bonus

# Clean object files
make clean

# Full clean (including library)
make fclean

# Recompile
make re
```

## Usage

```c
#include "libft.h"

int main(void)
{
    char *str = ft_strdup("Hello, World!");
    ft_putendl_fd(str, 1);
    free(str);
    return (0);
}
```

Compile with:
```bash
cc -Wall -Wextra -Werror main.c -L. -lft -o program
```

## Testing

You can test the library with various testers available online:
- libft-unit-test
- libft-war-machine
- Tripouille/libftTester

## Author

Implementation for 42 curriculum.
