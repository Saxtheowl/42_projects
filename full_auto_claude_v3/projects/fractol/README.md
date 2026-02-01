# Fract'ol

Fractal visualization tool (PPM output).

## Description

A fractal renderer supporting multiple fractal types with configurable parameters. Outputs to PPM image format for viewing with any image viewer.

## Fractals Supported

- **Mandelbrot**: The classic Mandelbrot set
- **Julia**: Julia sets with configurable constant
- **Burning Ship**: The Burning Ship fractal

## Usage

```bash
./fractol.py <fractal> [options] [output.ppm]
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `-w WIDTH` | Image width in pixels | 800 |
| `-h HEIGHT` | Image height in pixels | 600 |
| `-x CENTER_X` | X center coordinate | 0 |
| `-y CENTER_Y` | Y center coordinate | 0 |
| `-z ZOOM` | Zoom level | 1 |
| `-i MAX_ITER` | Maximum iterations | 100 |
| `-c SCHEME` | Color scheme (default/fire/psychedelic) | default |
| `-jr JC_REAL` | Julia constant real part | -0.7 |
| `-ji JC_IMAG` | Julia constant imaginary part | 0.27015 |

## Examples

```bash
# Basic Mandelbrot set
./fractol.py mandelbrot mandelbrot.ppm

# Julia set with fire colors
./fractol.py julia -c fire julia.ppm

# Zoomed Mandelbrot (seahorse valley)
./fractol.py mandelbrot -x -0.75 -y 0.1 -z 100 -i 200 zoom.ppm

# Burning Ship fractal
./fractol.py burning_ship -w 1920 -h 1080 ship.ppm

# Custom Julia set
./fractol.py julia -jr -0.4 -ji 0.6 custom_julia.ppm
```

## Viewing

```bash
# On Linux with ImageMagick
display output.ppm

# Convert to PNG
convert output.ppm output.png

# Open with default viewer
xdg-open output.ppm
```

## Color Schemes

- **default**: Blue to purple gradient
- **fire**: Red to yellow gradient
- **psychedelic**: Rainbow cycling

## Files

| File | Description |
|------|-------------|
| `fractol.py` | Main fractal renderer |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
