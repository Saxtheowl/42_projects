# Connect Four

Two-player Connect Four game with AI opponent.

## Description

Classic Connect Four game where players take turns dropping pieces into a 7-column, 6-row grid. The first player to connect four pieces horizontally, vertically, or diagonally wins.

## Features

- 7x6 game board
- Human vs AI gameplay
- Minimax algorithm with alpha-beta pruning
- Configurable search depth
- Win detection for horizontal, vertical, and diagonal lines

## Usage

```bash
./connect_four.py         # Play against AI
./connect_four.py --test  # Run test game
```

## Gameplay

- Enter column number (0-6) to drop your piece
- X = Player, O = AI
- First to connect 4 in a row wins

## AI Algorithm

The AI uses **Minimax with Alpha-Beta Pruning**:
- Searches game tree to configurable depth
- Evaluates positions based on:
  - Connected pieces (2, 3, or 4 in a row)
  - Center column control
  - Blocking opponent threats
- Alpha-beta pruning eliminates branches for efficiency

## Example

```
  0 1 2 3 4 5 6
  -------------
| . . . . . . . |
| . . . . . . . |
| . . . . . . . |
| . . . O . . . |
| . . . O O . . |
| . . . X X X X |
  -------------

X wins!
```

## Files

| File | Description |
|------|-------------|
| `connect_four.py` | Main game implementation |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
