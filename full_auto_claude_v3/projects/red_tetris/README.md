# Red Tetris - Classic Tetris Game

Terminal-based Tetris implementation with curses.

## Features

- All 7 tetromino shapes (I, O, T, S, Z, J, L)
- Color-coded pieces
- Rotation with wall kicks
- Hard drop
- Line clearing
- Score and level system
- Next piece preview

## Usage

```bash
# Play game
python tetris.py

# Watch demo
python tetris.py --demo

# Help
python tetris.py --help
```

## Controls

| Key | Action |
|-----|--------|
| ← / A | Move left |
| → / D | Move right |
| ↓ / S | Move down |
| ↑ / W | Rotate |
| Space | Hard drop |
| Q | Quit |

## Scoring

| Lines | Points |
|-------|--------|
| 1 | 40 × level |
| 2 | 100 × level |
| 3 | 300 × level |
| 4 (Tetris) | 1200 × level |

## Author

Implementation for 42 curriculum.
