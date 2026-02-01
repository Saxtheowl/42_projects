# FDF

3D wireframe renderer (PPM output).

## Description

Renders height map files as 3D wireframe projections using isometric view. Outputs to PPM image format.

## Usage

```bash
./fdf.py <map_file> [output.ppm] [options]
./fdf.py --sample [output.ppm]  # Generate sample
```

## Options

| Option | Description | Default |
|--------|-------------|---------|
| `-w WIDTH` | Image width | 800 |
| `-h HEIGHT` | Image height | 600 |
| `-z SCALE` | Z-axis scale | 0.2 |

## Map File Format

```
0 0 0 0 0
0 5 5 5 0
0 5 10 5 0
0 5 5 5 0
0 0 0 0 0
```

Each number represents the height at that grid position.

## Examples

```bash
# Render sample map
./fdf.py sample.fdf output.ppm

# Generate test image
./fdf.py --sample test.ppm

# High resolution with vertical exaggeration
./fdf.py sample.fdf -w 1920 -h 1080 -z 0.5 hd.ppm
```

## Features

- Isometric projection
- Height-based coloring (blue → cyan → green → yellow → red)
- Bresenham line algorithm for wireframe
- Automatic scaling to fit image

## Viewing

```bash
# View with ImageMagick
display output.ppm

# Convert to PNG
convert output.ppm output.png
```

## Files

| File | Description |
|------|-------------|
| `fdf.py` | Main renderer |
| `sample.fdf` | Sample height map |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
