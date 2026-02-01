# Game of Life - Conway's Cellular Automaton

Terminal-based implementation of Conway's Game of Life.

## Features

- Interactive simulation
- Wrap-around grid
- Multiple famous patterns
- Pause/resume
- Adjustable speed
- Pattern library

## Usage

```bash
# Interactive mode
python life.py

# Watch demo
python life.py --demo
```

## Controls

| Key | Action |
|-----|--------|
| Space | Pause/resume |
| R | Randomize |
| C | Clear grid |
| G | Add glider |
| B | Add glider gun |
| +/- | Speed up/down |
| Q | Quit |

## Rules

1. Live cell with 2-3 neighbors survives
2. Dead cell with exactly 3 neighbors becomes alive
3. All other cells die or stay dead

## Patterns

- **Glider**: Moves diagonally
- **Blinker**: Oscillates (period 2)
- **Block**: Still life (stable)
- **Beacon**: Oscillates (period 2)
- **Glider Gun**: Produces gliders
- **R-pentomino**: Long-lived chaos

## Author

Implementation for 42 curriculum.
