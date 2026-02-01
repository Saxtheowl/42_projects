# N-Puzzle Solver

A sliding puzzle solver using the A* algorithm with multiple heuristic options.

## Description

This program solves N-puzzle (sliding puzzle) problems of any size. It uses the A* search algorithm with selectable heuristics to find the optimal solution.

## Features

- Solves puzzles of any size (3x3, 4x4, 5x5, etc.)
- Multiple heuristic functions:
  - Manhattan distance
  - Hamming distance (misplaced tiles)
  - Linear conflict
- Solvability detection
- Snail/spiral goal pattern
- Displays complexity metrics

## Usage

```bash
chmod +x npuzzle.py
./npuzzle.py puzzle_file [heuristic]

# Examples:
./npuzzle.py puzzle3.txt
./npuzzle.py puzzle3.txt manhattan
./npuzzle.py puzzle3.txt linear_conflict
```

## Puzzle File Format

```
# Comments start with #
3                    # Size of puzzle
1 8 2               # First row
0 4 3               # 0 represents empty tile
7 6 5               # Third row
```

## Heuristics

### Manhattan Distance (default)
Sum of the horizontal and vertical distances of each tile from its goal position.

### Hamming Distance
Number of tiles that are not in their goal position.

### Linear Conflict
Manhattan distance plus additional cost for tiles that must pass each other in the same row or column.

## Goal State (Snail Pattern)

For a 3x3 puzzle:
```
1 2 3
8 0 4
7 6 5
```

For a 4x4 puzzle:
```
 1  2  3  4
12 13 14  5
11  0 15  6
10  9  8  7
```

## Example Output

```
Initial state (size 3x3):
 1  8  2
 0  4  3
 7  6  5

Goal state:
 1  2  3
 8  0  4
 7  6  5

Using heuristic: manhattan
Solving...

Solution found!
Number of moves: 9
Time complexity (states selected): 15
Space complexity (max states in memory): 21

Moves: Right -> Down -> Down -> Left -> Up -> Right -> Down -> Left -> Up
```

## Algorithm

The A* algorithm uses:
- f(n) = g(n) + h(n)
- g(n): Cost from start to current state (number of moves)
- h(n): Heuristic estimate of cost to goal

The algorithm explores states in order of f(n), guaranteed to find the optimal solution when using an admissible heuristic.

## Solvability

The puzzle checks solvability before attempting to solve:
- For odd-sized puzzles: solvable if inversions are even
- For even-sized puzzles: considers blank position from bottom

## Files

| File | Description |
|------|-------------|
| `npuzzle.py` | Main solver program |
| `puzzle3.txt` | Example 3x3 puzzle |
| `README.md` | Documentation |

## Generating Puzzles

You can create your own puzzle files or use a generator:

```python
# Simple random puzzle generator
import random

def generate_puzzle(size):
    tiles = list(range(size * size))
    random.shuffle(tiles)
    for i in range(size):
        print(" ".join(str(tiles[i*size + j]) for j in range(size)))
```

## Complexity

- Time: O(b^d) where b is branching factor and d is depth
- Space: O(b^d) for storing states

The heuristic choice significantly affects performance:
- Linear conflict is most accurate but slower to compute
- Manhattan is a good balance
- Hamming is fastest but least accurate

## Author

Implementation for 42 curriculum.
