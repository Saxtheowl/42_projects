# Push_swap

## Description

Push_swap is a sorting algorithm project. The goal is to sort a stack of integers using a limited set of operations with the minimum number of moves.

## Operations

| Operation | Description |
|-----------|-------------|
| `sa` | Swap first two elements of stack A |
| `sb` | Swap first two elements of stack B |
| `ss` | sa and sb simultaneously |
| `pa` | Push top of B to top of A |
| `pb` | Push top of A to top of B |
| `ra` | Rotate A (first becomes last) |
| `rb` | Rotate B (first becomes last) |
| `rr` | ra and rb simultaneously |
| `rra` | Reverse rotate A (last becomes first) |
| `rrb` | Reverse rotate B (last becomes first) |
| `rrr` | rra and rrb simultaneously |

## Algorithm

- For 2 elements: Simple swap if needed
- For 3 elements: Hardcoded optimal solution
- For 4-5 elements: Push minimum to B, sort remaining, push back
- For larger sets: Radix sort algorithm using binary representation

## Compilation

```bash
make
```

## Usage

```bash
./push_swap 5 2 3 1 4
# Output: Operations to sort the stack
```

## Testing

```bash
# Generate random numbers and count operations
ARG=$(shuf -i 1-100 -n 100 | tr '\n' ' '); ./push_swap $ARG | wc -l

# Verify sorting
ARG="5 2 3 1 4"; ./push_swap $ARG | ./checker $ARG
```

## Author

Implementation for 42 curriculum.
