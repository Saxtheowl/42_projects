# BSQ - Biggest Square Finder

A C program that finds the biggest square on a map while avoiding obstacles, implemented with clean code principles.

## Overview

This project solves the BSQ (Biggest Square) problem using dynamic programming. Given a map with empty spaces and obstacles, the program finds and marks the largest possible square that contains no obstacles.

## Features

- Finds the largest square in O(n*m) time complexity using DP
- Handles multiple input files
- Reads from stdin when no arguments provided
- Robust error handling for invalid maps
- Clean, modular code architecture

## Compilation

```bash
make        # Build the program
make clean  # Remove object files
make fclean # Remove object files and binary
make re     # Rebuild from scratch
```

## Usage

```bash
# Single file
./bsq map.txt

# Multiple files
./bsq map1.txt map2.txt map3.txt

# From stdin
cat map.txt | ./bsq
./bsq < map.txt
```

## Map Format

The first line contains:
- Number of rows (as a number)
- Empty character
- Obstacle character
- Full character (used to mark the solution)

Example map:
```
9.ox
...........................
....o......................
............o..............
...........................
....o......................
...............o...........
...........................
......o..............o.....
..o.......o................
```

Where:
- `9` = 9 rows
- `.` = empty space
- `o` = obstacle
- `x` = fill character for solution

## Output Example

```
.....xxxxxxx...............
....oxxxxxxx...............
.....xxxxxxxo..............
.....xxxxxxx...............
....oxxxxxxx...............
.....xxxxxxx...o...........
.....xxxxxxx...............
......o..............o.....
..o.......o................
```

The 7x7 square is marked with `x` characters.

## Project Structure

```
.
├── Makefile
├── README.md
├── include/
│   └── bsq.h           # Header with types and function prototypes
├── src/
│   ├── main.c          # Entry point and file processing
│   ├── map_parse.c     # Map parsing from file/stdin
│   ├── map_validate.c  # Map validation logic
│   ├── map_utils.c     # Map creation, freeing, printing
│   ├── solver.c        # DP algorithm for finding largest square
│   ├── io_utils.c      # File reading utilities
│   └── string_utils.c  # String manipulation functions
└── tests/
    └── test_bsq.sh     # Test suite
```

## Algorithm

The solution uses dynamic programming:

1. Create a DP table where `dp[i][j]` represents the size of the largest square with its bottom-right corner at position `(i, j)`

2. For each cell:
   - If it's an obstacle: `dp[i][j] = 0`
   - If it's empty: `dp[i][j] = min(dp[i-1][j], dp[i][j-1], dp[i-1][j-1]) + 1`

3. Track the maximum value and its position during iteration

4. Fill the solution square from `(row - size + 1, col - size + 1)` to `(row, col)`

Time Complexity: O(rows * cols)
Space Complexity: O(rows * cols)

## Clean Code Principles Applied

### Readability
- Descriptive function and variable names
- Single responsibility per function
- Consistent formatting

### Modularity
- Separation of concerns (parsing, validation, solving, I/O)
- Each file handles one aspect of the problem
- Easy to extend or modify individual components

### No Redundancy
- Common operations extracted to utility functions
- No code duplication across files

### Organization
- Intuitive directory structure
- Related functions grouped together
- Header file with clear API

## Error Handling

The program outputs "map error" to stderr for:
- Non-existent files
- Empty files
- Invalid header format
- Inconsistent line lengths
- Wrong number of rows
- Invalid characters in map
- Duplicate characters in header

## Testing

Run the test suite:

```bash
chmod +x tests/test_bsq.sh
./tests/test_bsq.sh
```

Tests cover:
- Basic functionality (various map sizes)
- Edge cases (1x1 maps, all obstacles, single empty cell)
- Different map shapes (wide, tall, rectangular)
- Multiple file processing
- Stdin input
- Invalid map detection
- Performance with large maps

## External Functions Used

- `open`, `close`, `read`, `write` - File I/O
- `malloc`, `free` - Memory management
- `exit` - Program termination

## Author

Generated for the 42 Fall 2021 Review Campaign - Code Refactoring exercise.
