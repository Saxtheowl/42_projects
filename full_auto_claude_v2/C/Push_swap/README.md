# Push_swap

A 42 school project - Sort data on a stack with a limited set of instructions, using the lowest possible number of actions.

## Description

Push_swap is a sorting algorithm project that challenges you to sort integers using only two stacks and a limited set of operations. The goal is to minimize the number of operations needed to sort the numbers.

## Operations

### Stack A and Stack B operations:
- `sa` - Swap the first 2 elements of stack a
- `sb` - Swap the first 2 elements of stack b
- `ss` - sa and sb at the same time
- `pa` - Push top element from b to a
- `pb` - Push top element from a to b
- `ra` - Rotate stack a up (first becomes last)
- `rb` - Rotate stack b up
- `rr` - ra and rb at the same time
- `rra` - Reverse rotate stack a down (last becomes first)
- `rrb` - Reverse rotate stack b down
- `rrr` - rra and rrb at the same time

## Compilation

```bash
make        # Compile push_swap
make bonus  # Compile checker
```

## Usage

### Push_swap
```bash
./push_swap 4 67 3 87 23
./push_swap "4 67 3 87 23"
```

The program outputs the list of operations to sort the numbers.

### Checker (Bonus)
```bash
./push_swap 4 67 3 87 23 | ./checker 4 67 3 87 23
```

The checker reads operations from stdin and outputs:
- `OK` if the stack is sorted
- `KO` if the stack is not sorted
- `Error` if there's an error

## Algorithm

The implementation uses different strategies based on stack size:

### Small Stacks (2-5 elements)
- **2 elements**: Single swap if needed
- **3 elements**: Hardcoded optimal solution (max 2 operations)
- **4-5 elements**: Push minimum values to stack b, sort remaining 3, push back

### Large Stacks (>5 elements)
- **Radix Sort**: Uses binary representation of indexed values
- Sorts bit by bit, achieving O(n log n) complexity
- Efficient for any size of input

## Performance Targets

- **3 numbers**: max 3 operations
- **5 numbers**: max 12 operations
- **100 numbers**: max 700 operations (5 points), max 900 (4 points)
- **500 numbers**: max 5500 operations (5 points), max 7000 (4 points)

## Features

- ✅ Handles negative numbers
- ✅ Handles duplicates (outputs error)
- ✅ Validates input (non-integers, overflow)
- ✅ Works with single argument or multiple arguments
- ✅ Efficient radix sort for large datasets
- ✅ Bonus checker program

## Error Handling

The program outputs `Error` followed by a newline on stderr for:
- Non-integer arguments
- Numbers larger than INT_MAX or smaller than INT_MIN
- Duplicate numbers
- Invalid input

## Example

```bash
$ ./push_swap 2 1 3 6 5 8
sa
pb
pb
pb
sa
pa
pa
pa

$ ./push_swap 2 1 3 6 5 8 | ./checker 2 1 3 6 5 8
OK

$ ./push_swap 0 one 2 3
Error
```

## Project Structure

- `push_swap.c` - Main program entry point
- `checker_bonus.c` - Bonus checker program
- `operations.c` - swap and push operations
- `rotate.c` - rotate and reverse rotate operations
- `stack_utils.c` - Stack creation and manipulation
- `stack_utils2.c` - Additional stack utilities
- `parse.c` - Argument parsing
- `validation.c` - Input validation and error checking
- `sort_small.c` - Sorting for small stacks (2-5 elements)
- `radix_sort.c` - Radix sort for large stacks
- `utils.c` - General utility functions
- `ft_split.c` - String splitting function
- `push_swap.h` - Header file

## Algorithm Complexity

- **Time Complexity**: O(n log n) for radix sort
- **Space Complexity**: O(n) for the stacks
- **Operation Count**: Optimized for the 42 evaluation criteria

## Author

Generated for 42 School project

## Acknowledgments

- 42 School for the subject
- Radix sort algorithm inspiration from various sources
