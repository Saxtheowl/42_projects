# ft_malloc - Custom Memory Allocator

Custom implementation of malloc, free, realloc, and calloc using mmap.

## Features

- Three zone types: TINY (<=128B), SMALL (<=1024B), LARGE
- Block splitting and coalescing
- Thread-safe with mutex
- Memory debugging with show_alloc_mem()
- No external dependencies (uses mmap)

## Building

```bash
# Build as shared library
make

# Build test program
make test
```

## Usage

### As Library

```c
#include "malloc.h"

void *ptr = malloc(100);
free(ptr);
```

### As Preloaded Library

```bash
export LD_PRELOAD=./libft_malloc.so
./your_program
```

## API

| Function | Description |
|----------|-------------|
| `malloc(size)` | Allocate memory |
| `free(ptr)` | Free memory |
| `realloc(ptr, size)` | Resize allocation |
| `calloc(n, size)` | Allocate zeroed memory |
| `show_alloc_mem()` | Debug: print memory map |

## Algorithm

1. **Zone Management**: Pre-allocate zones with mmap
2. **Block Splitting**: Split large blocks when allocating
3. **Coalescing**: Merge adjacent free blocks
4. **Large Allocations**: Direct mmap/munmap

## Author

Implementation for 42 curriculum.
