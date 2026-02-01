# so_long - 2D Tile-Based Game

A simple 2D game where player collects items and reaches exit.

## Features

- Tile-based map loading (.ber format)
- Map validation (walls, required elements)
- Player movement
- Collectible items
- PPM rendering with tile graphics

## Usage

```bash
# Render a map
python so_long.py map.ber

# Run demo with animation
python so_long.py --demo
```

## Map Format (.ber)

```
111111111
1P0C000E1
100000001
111111111
```

| Character | Description |
|-----------|-------------|
| 1 | Wall |
| 0 | Empty floor |
| P | Player start |
| C | Collectible |
| E | Exit |

## Rules

1. Collect all 'C' items
2. Reach exit 'E'
3. Cannot walk through walls '1'
4. Map must be surrounded by walls

## Output

Renders to PPM image files with:
- Brick pattern walls
- Coin collectibles
- Door exit
- Player character

## Author

Implementation for 42 curriculum.
