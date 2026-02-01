# Get Next Line

## Description

get_next_line is a function that reads a line from a file descriptor. It uses a static variable to store the buffer between function calls, allowing it to read files line by line.

## Prototype

```c
char *get_next_line(int fd);
```

## Parameters

- `fd`: The file descriptor to read from

## Return Value

- Returns the line that was read (including the newline character if present)
- Returns NULL if there is nothing else to read, or an error occurred

## Features

- Reads from any file descriptor (files, stdin, etc.)
- Uses a configurable BUFFER_SIZE
- Handles multiple consecutive reads
- Memory-safe implementation

## Compilation

```bash
# Compile with custom buffer size
cc -Wall -Wextra -Werror -D BUFFER_SIZE=42 get_next_line.c get_next_line_utils.c main.c

# Default buffer size is 42
```

## Usage

```c
#include "get_next_line.h"
#include <fcntl.h>
#include <stdio.h>

int main(void)
{
    int     fd;
    char    *line;

    fd = open("test.txt", O_RDONLY);
    if (fd == -1)
        return (1);

    while ((line = get_next_line(fd)) != NULL)
    {
        printf("%s", line);
        free(line);
    }
    close(fd);
    return (0);
}
```

## Files

- `get_next_line.h` - Header file with function prototypes
- `get_next_line.c` - Main function implementation
- `get_next_line_utils.c` - Utility functions

## Notes

- The function returns NULL when:
  - End of file is reached
  - An error occurs
  - Invalid file descriptor
- Memory allocated for the returned line must be freed by the caller
- The BUFFER_SIZE can be modified at compile time

## Author

Implementation for 42 curriculum.
