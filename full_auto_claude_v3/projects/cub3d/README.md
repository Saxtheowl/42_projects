# cub3D - Raycasting Engine

Wolfenstein 3D-inspired raycasting engine with PPM output.

## Features

- Raycasting with DDA algorithm
- Wall distance and perspective
- Directional wall coloring (N/S/E/W)
- Distance-based shading
- Minimap overlay
- Ceiling and floor colors
- Player movement and collision

## Usage

```bash
# Render a map
python cub3d.py map.cub

# Run demo with animation frames
python cub3d.py --demo
```

## Map Format (.cub)

```
NO ./textures/north.xpm    # North texture path
SO ./textures/south.xpm    # South texture path
WE ./textures/west.xpm     # West texture path
EA ./textures/east.xpm     # East texture path

F 100,80,60                # Floor color (R,G,B)
C 100,100,200              # Ceiling color (R,G,B)

111111111111111
100000000000001
100N00000000001            # N = Player facing North
100000000000001
111111111111111
```

## Map Characters

- `1` - Wall
- `0` - Empty space
- `N/S/E/W` - Player start + direction

## Algorithm

Uses Digital Differential Analyzer (DDA) for efficient raycasting:
1. Calculate ray direction for each screen column
2. Step through grid cells until wall hit
3. Calculate perpendicular distance (avoids fisheye)
4. Draw wall strip with distance shading

## Author

Implementation for 42 curriculum.
