# fract'ol

A 42 school project - Beautiful fractal explorer with real-time rendering and interactive controls.

## Description

fract'ol is a fractal visualization program that renders beautiful mathematical sets using the MiniLibX graphics library. The project explores complex number mathematics, optimization techniques, and interactive graphics programming.

## Features

### Mandatory
- **Mandelbrot Set**: Classic fractal showing the boundary of stability
- **Julia Set**: Parametric fractal with customizable complex constant
- **Mouse Wheel Zoom**: Smooth zooming that follows cursor position
- **Colorful Rendering**: Psychedelic color gradients based on iteration depth
- **Clean Exit**: ESC key and window close button

### Bonus
- **Burning Ship Fractal**: Third fractal type with unique flame-like patterns
- **Arrow Key Navigation**: Move the view in any direction
- **Iteration Control**: +/- keys to increase/decrease detail level
- **Color Shifting**: C key to cycle through color palettes

## Compilation

```bash
make
```

## Usage

### Mandelbrot Set
```bash
./fractol mandelbrot
```

### Julia Set
Requires two parameters (real and imaginary parts of the complex constant):
```bash
./fractol julia -0.7 0.27015
./fractol julia -0.8 0.156
./fractol julia 0.285 0.01
```

### Burning Ship
```bash
./fractol burning_ship
```

## Controls

| Key/Mouse | Action |
|-----------|--------|
| Mouse Wheel | Zoom in/out (follows cursor) |
| Arrow Keys | Move view up/down/left/right |
| + | Increase iterations (more detail) |
| - | Decrease iterations (faster rendering) |
| C | Shift color palette |
| ESC | Exit program |

## Fractals Explained

### Mandelbrot Set
The Mandelbrot set is defined by iterating the formula:
```
z(n+1) = z(n)² + c
```
Where z starts at 0 and c is the point being tested. Points that don't escape to infinity are in the set.

### Julia Set
Similar to Mandelbrot, but c is constant and z varies:
```
z(n+1) = z(n)² + c (where c is fixed)
```
Different c values produce completely different fractal shapes.

### Burning Ship
A variation using absolute values:
```
z(n+1) = (|Re(z)| + i|Im(z)|)² + c
```
Creates distinctive flame-like patterns.

## Mathematical Concepts

- **Complex Numbers**: Numbers with real and imaginary components
- **Iteration**: Repeatedly applying a function to its own output
- **Divergence**: Points that escape to infinity vs. those that remain bounded
- **Coloring**: Mapping iteration count to RGB values for visualization

## Project Structure

- `main.c` - Entry point and argument parsing
- `init.c` - Initialization of fractal parameters
- `fractals.c` - Mandelbrot, Julia, and Burning Ship algorithms
- `complex.c` - Complex number arithmetic
- `render.c` - Pixel rendering and color generation
- `events.c` - Keyboard and mouse event handlers
- `utils.c` - Utility functions
- `fractol.h` - Header file with structures and prototypes

## Requirements

- MiniLibX library
- X11 development libraries
- Math library

## Installation

```bash
# Install dependencies
sudo apt-get install gcc make xorg libxext-dev libbsd-dev

# Install MiniLibX (see install_mlx.sh from other projects)
```

## Examples

### Interesting Julia Set Parameters
- Classic: `./fractol julia -0.7 0.27015`
- Dendrite: `./fractol julia 0.285 0.01`
- Siegel Disk: `./fractol julia -0.391 -0.587`
- San Marco: `./fractol julia -0.75 0.1`

## Author

Generated for 42 School project

## Acknowledgments

- 42 School for the subject
- Benoit Mandelbrot for discovering fractals
- MiniLibX library developers
