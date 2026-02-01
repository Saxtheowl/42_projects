# guimp - Image Editor

Simple image manipulation tool with PPM format support.

## Features

### Drawing
- Lines (Bresenham's algorithm)
- Rectangles (filled/outline)
- Circles (midpoint algorithm)
- Ellipses
- Polygons (scanline fill)
- Flood fill

### Filters
- Grayscale conversion
- Color inversion
- Blur (box blur)
- Sharpen
- Edge detection
- Emboss

### Transforms
- Rotate (90, 180, 270 degrees)
- Flip horizontal/vertical
- Crop
- Resize (nearest neighbor)

## Usage

```bash
python3 guimp.py              # Run demo
python3 guimp.py image.ppm    # Process PPM file
```

## As a Library

```python
from guimp import Image, Color, RED, BLUE

# Create image
img = Image(800, 600, Color(255, 255, 255))

# Draw shapes
img.draw_rect(100, 100, 200, 150, RED, filled=True)
img.draw_circle(400, 300, 80, BLUE, filled=False)
img.draw_line(0, 0, 799, 599, Color(0, 0, 0))

# Apply filters
img.apply_filter("grayscale")
img.apply_filter("blur")

# Transform
rotated = img.rotate(90)
flipped = img.flip_horizontal()

# Save
img.save_ppm("output.ppm")
```

## Color Class

```python
color = Color(255, 128, 0)     # Orange
gray = color.grayscale()        # Convert to gray
inv = color.invert()            # Invert
bright = color.brightness(1.5)  # Brighten
blended = color.blend(other, 0.5)  # 50% blend
```

## Predefined Colors

| Constant | RGB |
|----------|-----|
| `BLACK` | (0, 0, 0) |
| `WHITE` | (255, 255, 255) |
| `RED` | (255, 0, 0) |
| `GREEN` | (0, 255, 0) |
| `BLUE` | (0, 0, 255) |
| `YELLOW` | (255, 255, 0) |
| `CYAN` | (0, 255, 255) |
| `MAGENTA` | (255, 0, 255) |

## PPM Format

The editor uses P3 (ASCII) PPM format:
- Universal, simple format
- Viewable with most image tools
- Easy to convert to other formats

## Author

Implementation for 42 curriculum.
