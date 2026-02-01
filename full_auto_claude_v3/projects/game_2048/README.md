# 2048

The classic sliding tile puzzle game.

## Description

2048 is a single-player puzzle game where you combine tiles with the same value to create larger numbers. The goal is to reach the 2048 tile.

## Features

- 4x4 game grid
- Score tracking
- Win detection (reaching 2048)
- Game over detection
- Optional auto-play mode

## Controls

| Key | Action |
|-----|--------|
| `w` | Move up |
| `s` | Move down |
| `a` | Move left |
| `d` | Move right |
| `q` | Quit |

## Usage

```bash
./game_2048.py          # Play manually
./game_2048.py --auto   # Watch AI play
```

## Rules

1. Use arrow keys to slide all tiles in one direction
2. When two tiles with the same number collide, they merge
3. After each move, a new tile (2 or 4) appears
4. Try to create a 2048 tile
5. Game ends when no moves are possible

## Example

```
Score: 128
+------+------+------+------+
|  4   |  8   |  16  |  32  |
+------+------+------+------+
|  2   |  .   |  2   |  16  |
+------+------+------+------+
|  .   |  .   |  4   |  8   |
+------+------+------+------+
|  .   |  2   |  .   |  4   |
+------+------+------+------+
```

## Files

| File | Description |
|------|-------------|
| `game_2048.py` | Main game implementation |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
