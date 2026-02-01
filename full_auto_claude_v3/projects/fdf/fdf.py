#!/usr/bin/env python3
"""
FDF - 3D Wireframe Renderer (outputs to PPM file)
Renders height maps as 3D wireframe projections.
"""

import sys
import math
from typing import List, Tuple, Optional


class Point3D:
    def __init__(self, x: float, y: float, z: float):
        self.x = x
        self.y = y
        self.z = z


class Point2D:
    def __init__(self, x: int, y: int):
        self.x = x
        self.y = y


def parse_map(filename: str) -> List[List[int]]:
    """Parse a height map file."""
    height_map = []
    with open(filename, 'r') as f:
        for line in f:
            row = []
            for value in line.strip().split():
                # Handle color suffix (e.g., "10,0xFF0000")
                if ',' in value:
                    value = value.split(',')[0]
                row.append(int(value))
            if row:
                height_map.append(row)
    return height_map


def rotate_x(point: Point3D, angle: float) -> Point3D:
    """Rotate point around X axis."""
    cos_a = math.cos(angle)
    sin_a = math.sin(angle)
    return Point3D(
        point.x,
        point.y * cos_a - point.z * sin_a,
        point.y * sin_a + point.z * cos_a
    )


def rotate_y(point: Point3D, angle: float) -> Point3D:
    """Rotate point around Y axis."""
    cos_a = math.cos(angle)
    sin_a = math.sin(angle)
    return Point3D(
        point.x * cos_a + point.z * sin_a,
        point.y,
        -point.x * sin_a + point.z * cos_a
    )


def rotate_z(point: Point3D, angle: float) -> Point3D:
    """Rotate point around Z axis."""
    cos_a = math.cos(angle)
    sin_a = math.sin(angle)
    return Point3D(
        point.x * cos_a - point.y * sin_a,
        point.x * sin_a + point.y * cos_a,
        point.z
    )


def isometric_project(point: Point3D, scale: float, offset_x: int, offset_y: int) -> Point2D:
    """Project 3D point to 2D using isometric projection."""
    # Rotate for isometric view
    angle = math.pi / 6  # 30 degrees
    rotated = rotate_z(rotate_x(point, angle), -angle)
    
    x = int(rotated.x * scale + offset_x)
    y = int(rotated.y * scale + offset_y)
    
    return Point2D(x, y)


def get_color_from_height(height: int, min_h: int, max_h: int) -> Tuple[int, int, int]:
    """Get color based on height (blue to red gradient)."""
    if max_h == min_h:
        return (255, 255, 255)
    
    t = (height - min_h) / (max_h - min_h)
    
    if t < 0.25:
        # Blue to cyan
        return (0, int(255 * t * 4), 255)
    elif t < 0.5:
        # Cyan to green
        return (0, 255, int(255 * (1 - (t - 0.25) * 4)))
    elif t < 0.75:
        # Green to yellow
        return (int(255 * (t - 0.5) * 4), 255, 0)
    else:
        # Yellow to red
        return (255, int(255 * (1 - (t - 0.75) * 4)), 0)


def draw_line(pixels: List[List[Tuple[int, int, int]]], 
              p1: Point2D, p2: Point2D, 
              color: Tuple[int, int, int],
              width: int, height: int):
    """Draw a line using Bresenham's algorithm."""
    dx = abs(p2.x - p1.x)
    dy = abs(p2.y - p1.y)
    sx = 1 if p1.x < p2.x else -1
    sy = 1 if p1.y < p2.y else -1
    err = dx - dy
    
    x, y = p1.x, p1.y
    
    while True:
        if 0 <= x < width and 0 <= y < height:
            pixels[y][x] = color
        
        if x == p2.x and y == p2.y:
            break
        
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x += sx
        if e2 < dx:
            err += dx
            y += sy


def render_fdf(height_map: List[List[int]], 
               img_width: int, img_height: int,
               z_scale: float = 1.0) -> List[List[Tuple[int, int, int]]]:
    """Render height map to wireframe image."""
    rows = len(height_map)
    cols = len(height_map[0]) if rows > 0 else 0
    
    if rows == 0 or cols == 0:
        return []
    
    # Find height range
    min_h = min(min(row) for row in height_map)
    max_h = max(max(row) for row in height_map)
    
    # Initialize pixels (black background)
    pixels = [[(0, 0, 0) for _ in range(img_width)] for _ in range(img_height)]
    
    # Calculate scale and offset
    scale = min(img_width / (cols * 2), img_height / (rows * 2)) * 0.8
    offset_x = img_width // 2
    offset_y = img_height // 4
    
    # Create 3D points
    points_3d = []
    for r in range(rows):
        row_points = []
        for c in range(cols):
            x = c - cols / 2
            y = r - rows / 2
            z = height_map[r][c] * z_scale
            row_points.append(Point3D(x, y, z))
        points_3d.append(row_points)
    
    # Project to 2D
    points_2d = []
    for r in range(rows):
        row_points = []
        for c in range(cols):
            p2d = isometric_project(points_3d[r][c], scale, offset_x, offset_y)
            row_points.append(p2d)
        points_2d.append(row_points)
    
    # Draw wireframe
    for r in range(rows):
        for c in range(cols):
            color = get_color_from_height(height_map[r][c], min_h, max_h)
            
            # Draw line to right neighbor
            if c + 1 < cols:
                draw_line(pixels, points_2d[r][c], points_2d[r][c + 1], 
                         color, img_width, img_height)
            
            # Draw line to bottom neighbor
            if r + 1 < rows:
                draw_line(pixels, points_2d[r][c], points_2d[r + 1][c], 
                         color, img_width, img_height)
    
    return pixels


def write_ppm(filename: str, pixels: List[List[Tuple[int, int, int]]]):
    """Write pixels to a PPM file."""
    height = len(pixels)
    width = len(pixels[0]) if height > 0 else 0
    
    with open(filename, 'w') as f:
        f.write(f"P3\n{width} {height}\n255\n")
        for row in pixels:
            for r, g, b in row:
                f.write(f"{r} {g} {b} ")
            f.write("\n")
    
    print(f"Saved to {filename}")


def generate_sample_map(size: int = 10) -> List[List[int]]:
    """Generate a sample height map for testing."""
    height_map = []
    for y in range(size):
        row = []
        for x in range(size):
            # Create a simple hill
            cx, cy = size / 2, size / 2
            dist = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            height = int(max(0, 5 - dist))
            row.append(height)
        height_map.append(row)
    return height_map


def main():
    if len(sys.argv) < 2:
        print("Usage: fdf.py <map_file> [output.ppm] [options]")
        print()
        print("Options:")
        print("  -w WIDTH    Image width (default: 800)")
        print("  -h HEIGHT   Image height (default: 600)")
        print("  -z SCALE    Z-axis scale (default: 0.2)")
        print()
        print("Map file format:")
        print("  Each line contains space-separated height values")
        print("  Optional color: value,0xRRGGBB")
        print()
        print("Example:")
        print("  ./fdf.py map.fdf output.ppm")
        print("  ./fdf.py --sample test.ppm  (generate sample)")
        return
    
    # Default parameters
    img_width = 800
    img_height = 600
    z_scale = 0.2
    output_file = "output.ppm"
    input_file = None
    
    # Parse arguments
    i = 1
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "-w" and i + 1 < len(sys.argv):
            img_width = int(sys.argv[i + 1])
            i += 2
        elif arg == "-h" and i + 1 < len(sys.argv):
            img_height = int(sys.argv[i + 1])
            i += 2
        elif arg == "-z" and i + 1 < len(sys.argv):
            z_scale = float(sys.argv[i + 1])
            i += 2
        elif arg == "--sample":
            input_file = "--sample"
            i += 1
        elif arg.endswith(".ppm"):
            output_file = arg
            i += 1
        elif arg.endswith(".fdf") or not arg.startswith("-"):
            input_file = arg
            i += 1
        else:
            i += 1
    
    # Load or generate height map
    if input_file == "--sample":
        print("Generating sample height map...")
        height_map = generate_sample_map(20)
    elif input_file:
        print(f"Loading {input_file}...")
        height_map = parse_map(input_file)
    else:
        print("Error: No input file specified")
        return
    
    print(f"Map size: {len(height_map[0])}x{len(height_map)}")
    
    # Render
    print("Rendering...")
    pixels = render_fdf(height_map, img_width, img_height, z_scale)
    
    # Save
    write_ppm(output_file, pixels)


if __name__ == "__main__":
    main()
