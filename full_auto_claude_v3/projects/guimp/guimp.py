#!/usr/bin/env python3
"""
guimp - Image Editor
Simple image manipulation tool with PPM output
"""

import sys
import os
from dataclasses import dataclass
from typing import List, Tuple, Optional
import math


@dataclass
class Color:
    """RGB color."""
    r: int
    g: int
    b: int

    def __post_init__(self):
        self.r = max(0, min(255, self.r))
        self.g = max(0, min(255, self.g))
        self.b = max(0, min(255, self.b))

    def blend(self, other: 'Color', alpha: float) -> 'Color':
        """Blend with another color."""
        return Color(
            int(self.r * (1 - alpha) + other.r * alpha),
            int(self.g * (1 - alpha) + other.g * alpha),
            int(self.b * (1 - alpha) + other.b * alpha)
        )

    def invert(self) -> 'Color':
        """Invert color."""
        return Color(255 - self.r, 255 - self.g, 255 - self.b)

    def grayscale(self) -> 'Color':
        """Convert to grayscale."""
        gray = int(0.299 * self.r + 0.587 * self.g + 0.114 * self.b)
        return Color(gray, gray, gray)

    def brightness(self, factor: float) -> 'Color':
        """Adjust brightness."""
        return Color(
            int(self.r * factor),
            int(self.g * factor),
            int(self.b * factor)
        )


# Predefined colors
BLACK = Color(0, 0, 0)
WHITE = Color(255, 255, 255)
RED = Color(255, 0, 0)
GREEN = Color(0, 255, 0)
BLUE = Color(0, 0, 255)
YELLOW = Color(255, 255, 0)
CYAN = Color(0, 255, 255)
MAGENTA = Color(255, 0, 255)


class Image:
    """Image class with drawing operations."""

    def __init__(self, width: int, height: int, bg_color: Color = WHITE):
        self.width = width
        self.height = height
        self.pixels = [[Color(bg_color.r, bg_color.g, bg_color.b)
                       for _ in range(width)]
                       for _ in range(height)]

    def in_bounds(self, x: int, y: int) -> bool:
        """Check if coordinates are in bounds."""
        return 0 <= x < self.width and 0 <= y < self.height

    def set_pixel(self, x: int, y: int, color: Color):
        """Set a pixel color."""
        if self.in_bounds(x, y):
            self.pixels[y][x] = color

    def get_pixel(self, x: int, y: int) -> Color:
        """Get a pixel color."""
        if self.in_bounds(x, y):
            return self.pixels[y][x]
        return BLACK

    def fill(self, color: Color):
        """Fill entire image with color."""
        for y in range(self.height):
            for x in range(self.width):
                self.pixels[y][x] = Color(color.r, color.g, color.b)

    def draw_line(self, x1: int, y1: int, x2: int, y2: int, color: Color):
        """Draw a line using Bresenham's algorithm."""
        dx = abs(x2 - x1)
        dy = abs(y2 - y1)
        sx = 1 if x1 < x2 else -1
        sy = 1 if y1 < y2 else -1
        err = dx - dy

        x, y = x1, y1
        while True:
            self.set_pixel(x, y, color)
            if x == x2 and y == y2:
                break
            e2 = 2 * err
            if e2 > -dy:
                err -= dy
                x += sx
            if e2 < dx:
                err += dx
                y += sy

    def draw_rect(self, x: int, y: int, w: int, h: int, color: Color, filled: bool = False):
        """Draw a rectangle."""
        if filled:
            for py in range(y, y + h):
                for px in range(x, x + w):
                    self.set_pixel(px, py, color)
        else:
            self.draw_line(x, y, x + w - 1, y, color)  # Top
            self.draw_line(x, y + h - 1, x + w - 1, y + h - 1, color)  # Bottom
            self.draw_line(x, y, x, y + h - 1, color)  # Left
            self.draw_line(x + w - 1, y, x + w - 1, y + h - 1, color)  # Right

    def draw_circle(self, cx: int, cy: int, radius: int, color: Color, filled: bool = False):
        """Draw a circle using midpoint algorithm."""
        if filled:
            for y in range(-radius, radius + 1):
                for x in range(-radius, radius + 1):
                    if x * x + y * y <= radius * radius:
                        self.set_pixel(cx + x, cy + y, color)
        else:
            x = 0
            y = radius
            d = 1 - radius

            while x <= y:
                self.set_pixel(cx + x, cy + y, color)
                self.set_pixel(cx - x, cy + y, color)
                self.set_pixel(cx + x, cy - y, color)
                self.set_pixel(cx - x, cy - y, color)
                self.set_pixel(cx + y, cy + x, color)
                self.set_pixel(cx - y, cy + x, color)
                self.set_pixel(cx + y, cy - x, color)
                self.set_pixel(cx - y, cy - x, color)

                if d < 0:
                    d += 2 * x + 3
                else:
                    d += 2 * (x - y) + 5
                    y -= 1
                x += 1

    def draw_ellipse(self, cx: int, cy: int, rx: int, ry: int, color: Color, filled: bool = False):
        """Draw an ellipse."""
        if filled:
            for y in range(-ry, ry + 1):
                for x in range(-rx, rx + 1):
                    if (x * x) / (rx * rx) + (y * y) / (ry * ry) <= 1:
                        self.set_pixel(cx + x, cy + y, color)
        else:
            for angle in range(360):
                rad = math.radians(angle)
                x = int(cx + rx * math.cos(rad))
                y = int(cy + ry * math.sin(rad))
                self.set_pixel(x, y, color)

    def draw_polygon(self, points: List[Tuple[int, int]], color: Color, filled: bool = False):
        """Draw a polygon."""
        if len(points) < 2:
            return

        if filled:
            # Scanline fill
            min_y = min(p[1] for p in points)
            max_y = max(p[1] for p in points)

            for y in range(min_y, max_y + 1):
                intersections = []
                for i in range(len(points)):
                    p1 = points[i]
                    p2 = points[(i + 1) % len(points)]

                    if p1[1] == p2[1]:
                        continue

                    if min(p1[1], p2[1]) <= y < max(p1[1], p2[1]):
                        x = p1[0] + (y - p1[1]) * (p2[0] - p1[0]) / (p2[1] - p1[1])
                        intersections.append(int(x))

                intersections.sort()
                for i in range(0, len(intersections) - 1, 2):
                    for x in range(intersections[i], intersections[i + 1] + 1):
                        self.set_pixel(x, y, color)
        else:
            for i in range(len(points)):
                p1 = points[i]
                p2 = points[(i + 1) % len(points)]
                self.draw_line(p1[0], p1[1], p2[0], p2[1], color)

    def flood_fill(self, x: int, y: int, color: Color):
        """Flood fill from a point."""
        if not self.in_bounds(x, y):
            return

        target = self.get_pixel(x, y)
        if (target.r == color.r and target.g == color.g and target.b == color.b):
            return

        stack = [(x, y)]
        while stack:
            px, py = stack.pop()
            if not self.in_bounds(px, py):
                continue

            current = self.get_pixel(px, py)
            if current.r != target.r or current.g != target.g or current.b != target.b:
                continue

            self.set_pixel(px, py, color)
            stack.extend([(px + 1, py), (px - 1, py), (px, py + 1), (px, py - 1)])

    def apply_filter(self, filter_name: str):
        """Apply a filter to the image."""
        if filter_name == "grayscale":
            for y in range(self.height):
                for x in range(self.width):
                    self.pixels[y][x] = self.pixels[y][x].grayscale()

        elif filter_name == "invert":
            for y in range(self.height):
                for x in range(self.width):
                    self.pixels[y][x] = self.pixels[y][x].invert()

        elif filter_name == "blur":
            self._apply_convolution([
                [1/9, 1/9, 1/9],
                [1/9, 1/9, 1/9],
                [1/9, 1/9, 1/9]
            ])

        elif filter_name == "sharpen":
            self._apply_convolution([
                [0, -1, 0],
                [-1, 5, -1],
                [0, -1, 0]
            ])

        elif filter_name == "edge":
            self._apply_convolution([
                [-1, -1, -1],
                [-1, 8, -1],
                [-1, -1, -1]
            ])

        elif filter_name == "emboss":
            self._apply_convolution([
                [-2, -1, 0],
                [-1, 1, 1],
                [0, 1, 2]
            ])

    def _apply_convolution(self, kernel: List[List[float]]):
        """Apply a convolution kernel."""
        kh = len(kernel)
        kw = len(kernel[0])
        offset_y = kh // 2
        offset_x = kw // 2

        new_pixels = [[Color(0, 0, 0) for _ in range(self.width)]
                      for _ in range(self.height)]

        for y in range(self.height):
            for x in range(self.width):
                r_sum = g_sum = b_sum = 0.0

                for ky in range(kh):
                    for kx in range(kw):
                        py = y + ky - offset_y
                        px = x + kx - offset_x

                        if self.in_bounds(px, py):
                            pixel = self.pixels[py][px]
                            k = kernel[ky][kx]
                            r_sum += pixel.r * k
                            g_sum += pixel.g * k
                            b_sum += pixel.b * k

                new_pixels[y][x] = Color(int(r_sum), int(g_sum), int(b_sum))

        self.pixels = new_pixels

    def rotate(self, degrees: int) -> 'Image':
        """Rotate image by 90, 180, or 270 degrees."""
        if degrees == 90:
            new_img = Image(self.height, self.width)
            for y in range(self.height):
                for x in range(self.width):
                    new_img.pixels[x][self.height - 1 - y] = self.pixels[y][x]
            return new_img

        elif degrees == 180:
            new_img = Image(self.width, self.height)
            for y in range(self.height):
                for x in range(self.width):
                    new_img.pixels[self.height - 1 - y][self.width - 1 - x] = self.pixels[y][x]
            return new_img

        elif degrees == 270:
            new_img = Image(self.height, self.width)
            for y in range(self.height):
                for x in range(self.width):
                    new_img.pixels[self.width - 1 - x][y] = self.pixels[y][x]
            return new_img

        return self

    def flip_horizontal(self) -> 'Image':
        """Flip image horizontally."""
        new_img = Image(self.width, self.height)
        for y in range(self.height):
            for x in range(self.width):
                new_img.pixels[y][self.width - 1 - x] = self.pixels[y][x]
        return new_img

    def flip_vertical(self) -> 'Image':
        """Flip image vertically."""
        new_img = Image(self.width, self.height)
        for y in range(self.height):
            for x in range(self.width):
                new_img.pixels[self.height - 1 - y][x] = self.pixels[y][x]
        return new_img

    def crop(self, x: int, y: int, w: int, h: int) -> 'Image':
        """Crop image."""
        new_img = Image(w, h)
        for py in range(h):
            for px in range(w):
                if self.in_bounds(x + px, y + py):
                    new_img.pixels[py][px] = self.pixels[y + py][x + px]
        return new_img

    def resize(self, new_width: int, new_height: int) -> 'Image':
        """Resize image using nearest neighbor."""
        new_img = Image(new_width, new_height)
        x_ratio = self.width / new_width
        y_ratio = self.height / new_height

        for y in range(new_height):
            for x in range(new_width):
                src_x = int(x * x_ratio)
                src_y = int(y * y_ratio)
                if self.in_bounds(src_x, src_y):
                    new_img.pixels[y][x] = self.pixels[src_y][src_x]

        return new_img

    def save_ppm(self, filename: str):
        """Save image as PPM."""
        with open(filename, 'w') as f:
            f.write("P3\n")
            f.write(f"{self.width} {self.height}\n")
            f.write("255\n")

            for row in self.pixels:
                for pixel in row:
                    f.write(f"{pixel.r} {pixel.g} {pixel.b}\n")

        print(f"Saved: {filename}")

    @staticmethod
    def load_ppm(filename: str) -> 'Image':
        """Load a PPM file."""
        with open(filename, 'r') as f:
            magic = f.readline().strip()
            if magic != 'P3':
                raise ValueError("Only P3 PPM format supported")

            # Skip comments
            line = f.readline()
            while line.startswith('#'):
                line = f.readline()

            width, height = map(int, line.split())
            max_val = int(f.readline().strip())

            img = Image(width, height)

            values = []
            for line in f:
                values.extend(map(int, line.split()))

            idx = 0
            for y in range(height):
                for x in range(width):
                    r = values[idx] * 255 // max_val
                    g = values[idx + 1] * 255 // max_val
                    b = values[idx + 2] * 255 // max_val
                    img.pixels[y][x] = Color(r, g, b)
                    idx += 3

            return img


def run_demo():
    """Run demonstration of image operations."""
    print("guimp - Image Editor Demo")
    print("=" * 50)

    # Create demo image
    img = Image(400, 300, WHITE)

    # Draw gradient background
    for y in range(300):
        for x in range(400):
            r = int(255 * x / 400)
            g = int(255 * y / 300)
            b = 128
            img.set_pixel(x, y, Color(r, g, b))

    # Draw shapes
    img.draw_rect(50, 50, 100, 80, RED, filled=True)
    img.draw_rect(45, 45, 110, 90, BLACK, filled=False)

    img.draw_circle(250, 100, 50, BLUE, filled=True)
    img.draw_circle(250, 100, 55, BLACK, filled=False)

    img.draw_ellipse(150, 200, 60, 30, GREEN, filled=True)

    # Draw polygon (star)
    star_points = []
    cx, cy = 320, 220
    for i in range(5):
        angle1 = math.radians(i * 72 - 90)
        angle2 = math.radians(i * 72 + 36 - 90)
        star_points.append((int(cx + 40 * math.cos(angle1)), int(cy + 40 * math.sin(angle1))))
        star_points.append((int(cx + 20 * math.cos(angle2)), int(cy + 20 * math.sin(angle2))))
    img.draw_polygon(star_points, YELLOW, filled=True)

    # Draw lines
    for i in range(0, 400, 20):
        img.draw_line(0, 299, i, 0, Color(100, 100, 100))

    # Save original
    img.save_ppm("demo_original.ppm")
    print("Created: demo_original.ppm")

    # Apply filters and save
    img_gray = Image(img.width, img.height)
    for y in range(img.height):
        for x in range(img.width):
            img_gray.pixels[y][x] = Color(img.pixels[y][x].r,
                                          img.pixels[y][x].g,
                                          img.pixels[y][x].b)
    img_gray.apply_filter("grayscale")
    img_gray.save_ppm("demo_grayscale.ppm")

    img_inv = Image(img.width, img.height)
    for y in range(img.height):
        for x in range(img.width):
            img_inv.pixels[y][x] = Color(img.pixels[y][x].r,
                                         img.pixels[y][x].g,
                                         img.pixels[y][x].b)
    img_inv.apply_filter("invert")
    img_inv.save_ppm("demo_inverted.ppm")

    # Rotate
    rotated = img.rotate(90)
    rotated.save_ppm("demo_rotated90.ppm")

    # Flip
    flipped = img.flip_horizontal()
    flipped.save_ppm("demo_flipped.ppm")

    print("\n" + "=" * 50)
    print("Demo complete! Generated PPM files:")
    print("  - demo_original.ppm")
    print("  - demo_grayscale.ppm")
    print("  - demo_inverted.ppm")
    print("  - demo_rotated90.ppm")
    print("  - demo_flipped.ppm")
    print("=" * 50)


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("guimp - Simple Image Editor")
            print("\nUsage:")
            print("  python guimp.py           - Run demo")
            print("  python guimp.py <file>    - Load and process PPM file")
            print("\nSupported operations:")
            print("  - Drawing: line, rect, circle, ellipse, polygon")
            print("  - Filters: grayscale, invert, blur, sharpen, edge, emboss")
            print("  - Transform: rotate, flip, crop, resize")
            print("  - Fill: flood fill")
            return

        # Load and process file
        if os.path.exists(sys.argv[1]):
            print(f"Loading: {sys.argv[1]}")
            img = Image.load_ppm(sys.argv[1])
            print(f"Size: {img.width}x{img.height}")

            # Apply grayscale as demo
            img.apply_filter("grayscale")
            output = sys.argv[1].replace('.ppm', '_processed.ppm')
            img.save_ppm(output)
            return

    run_demo()


if __name__ == "__main__":
    main()
