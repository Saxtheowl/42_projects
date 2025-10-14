# FDF (Fil de Fer / Wireframe)

A 42 school project - 3D wireframe representation of relief landscapes using isometric projection.

## Description

FDF creates a 3D wireframe visualization of terrain maps. It reads height map data from `.fdf` files and displays them using isometric projection with MiniLibX.

## Features

- **Isometric Projection**: 3D visualization with 45° rotation
- **Wireframe Rendering**: Lines connecting adjacent points
- **File Parsing**: Reads .fdf format map files
- **Color Gradients**: Height-based coloring
- **ESC to Exit**: Clean window management

## Compilation

```bash
make
```

## Usage

```bash
./fdf test_maps/42.fdf
```

## Map Format

Maps are text files with `.fdf` extension containing space-separated integers:
- Horizontal position = x coordinate
- Vertical position = y coordinate
- Integer value = altitude (z)

Example `42.fdf`:
```
0 0 0 0 0 0 0
0 0 0 0 0 0 0
0 0 10 10 0 0 0
0 0 10 10 0 0 0
0 0 10 10 10 10 0
0 0 0 10 10 0 0
0 0 0 0 0 0 0
```

## Project Structure

- `main.c` - Entry point and initialization
- `parse.c` - Map file parsing
- `draw.c` - Bresenham line drawing
- `project.c` - Isometric projection
- `render.c` - Map rendering
- `events.c` - Keyboard event handlers
- `utils.c` - Utility functions
- `Makefile` - Build system

## Algorithm: Bresenham's Line

Efficiently draws lines between points using only integer arithmetic.

## Algorithm: Isometric Projection

Converts 3D coordinates (x, y, z) to 2D screen space:
```
x' = (x - y) * cos(30°)
y' = (x + y) * sin(30°) - z
```

## Controls

- `ESC` - Exit program

## Requirements

- MiniLibX library
- X11 development libraries
- Math library

## Installation

```bash
# Install dependencies
sudo apt-get install gcc make xorg libxext-dev libbsd-dev

# Install MiniLibX (see install_mlx.sh from So_Long project)
```

## Author

Generated for 42 School project

## Acknowledgments

- 42 School for the subject
- MiniLibX library developers
