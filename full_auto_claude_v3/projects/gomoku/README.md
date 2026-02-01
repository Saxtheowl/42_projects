# Gomoku

Five in a row game with AI opponent.

## Description

Gomoku (also called Five in a Row) is a strategy game where players take turns placing stones on a 15x15 board. The first player to get exactly five stones in a row (horizontally, vertically, or diagonally) wins.

## Features

- 15x15 game board
- Human vs AI gameplay
- Minimax algorithm with alpha-beta pruning
- Position evaluation based on:
  - Connected stones
  - Open ends
  - Threat detection

## Controls

Enter row and column numbers separated by space (e.g., `7 7` for center).

## Usage

```bash
./gomoku.py
```

## Example

```
Gomoku - Five in a Row!
You are X, AI is O
Enter row and column (e.g., '7 7')

    0 1 2 3 4 5 6 7 8 910111213 14
 0  . . . . . . . . . . . . . . .
 1  . . . . . . . . . . . . . . .
 2  . . . . . . . . . . . . . . .
 3  . . . . . . . . . . . . . . .
 4  . . . . . . . . . . . . . . .
 5  . . . . . . O . . . . . . . .
 6  . . . . . . X X . . . . . . .
 7  . . . . . . . X . . . . . . .
 8  . . . . . . O X . . . . . . .
 9  . . . . . . . . . . . . . . .

Your move (X):
```

## AI Algorithm

The AI uses **Minimax with Alpha-Beta Pruning**:
- Searches game tree to depth 3
- Evaluates positions based on:
  - Lines of 2, 3, 4, 5 stones
  - Open vs closed lines
  - Blocking opponent threats

## Files

| File | Description |
|------|-------------|
| `gomoku.py` | Main game implementation |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
