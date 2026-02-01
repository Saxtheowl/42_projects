#!/usr/bin/env python3
"""
Fract'ol - Fractal visualization (outputs to PPM file)
Supports Mandelbrot, Julia, and Burning Ship fractals.
"""

import sys
from typing import Tuple, List


def mandelbrot(c_real: float, c_imag: float, max_iter: int) -> int:
    """Calculate Mandelbrot set iterations."""
    z_real, z_imag = 0.0, 0.0
    for i in range(max_iter):
        z_real_sq = z_real * z_real
        z_imag_sq = z_imag * z_imag
        if z_real_sq + z_imag_sq > 4.0:
            return i
        z_imag = 2.0 * z_real * z_imag + c_imag
        z_real = z_real_sq - z_imag_sq + c_real
    return max_iter


def julia(z_real: float, z_imag: float, c_real: float, c_imag: float, max_iter: int) -> int:
    """Calculate Julia set iterations."""
    for i in range(max_iter):
        z_real_sq = z_real * z_real
        z_imag_sq = z_imag * z_imag
        if z_real_sq + z_imag_sq > 4.0:
            return i
        z_imag = 2.0 * z_real * z_imag + c_imag
        z_real = z_real_sq - z_imag_sq + c_real
    return max_iter


def burning_ship(c_real: float, c_imag: float, max_iter: int) -> int:
    """Calculate Burning Ship fractal iterations."""
    z_real, z_imag = 0.0, 0.0
    for i in range(max_iter):
        z_real_sq = z_real * z_real
        z_imag_sq = z_imag * z_imag
        if z_real_sq + z_imag_sq > 4.0:
            return i
        z_imag = abs(2.0 * z_real * z_imag) + c_imag
        z_real = z_real_sq - z_imag_sq + c_real
    return max_iter


def get_color(iterations: int, max_iter: int) -> Tuple[int, int, int]:
    """Convert iteration count to RGB color."""
    if iterations == max_iter:
        return (0, 0, 0)  # Black for points in set
    
    # Create a smooth color gradient
    t = iterations / max_iter
    
    # Cycle through colors
    r = int(9 * (1 - t) * t * t * t * 255)
    g = int(15 * (1 - t) * (1 - t) * t * t * 255)
    b = int(8.5 * (1 - t) * (1 - t) * (1 - t) * t * 255)
    
    return (min(255, r), min(255, g), min(255, b))


def get_color_fire(iterations: int, max_iter: int) -> Tuple[int, int, int]:
    """Fire color scheme."""
    if iterations == max_iter:
        return (0, 0, 0)
    
    t = iterations / max_iter
    r = int(min(255, 512 * t))
    g = int(min(255, 512 * t - 128) if t > 0.25 else 0)
    b = int(min(255, 512 * t - 256) if t > 0.5 else 0)
    
    return (r, g, b)


def get_color_psychedelic(iterations: int, max_iter: int) -> Tuple[int, int, int]:
    """Psychedelic color scheme."""
    if iterations == max_iter:
        return (0, 0, 0)
    
    t = iterations % 64 / 64.0
    r = int(127.5 * (1 + sin(t * 6.28)))
    g = int(127.5 * (1 + sin(t * 6.28 + 2.09)))
    b = int(127.5 * (1 + sin(t * 6.28 + 4.19)))
    
    return (r, g, b)


def sin(x: float) -> float:
    """Simple sine approximation."""
    import math
    return math.sin(x)


def render_fractal(fractal_type: str, width: int, height: int, 
                   x_center: float, y_center: float, zoom: float,
                   max_iter: int = 100, color_scheme: str = "default",
                   julia_c: Tuple[float, float] = (-0.7, 0.27015)) -> List[List[Tuple[int, int, int]]]:
    """Render a fractal to a 2D pixel array."""
    pixels = []
    
    aspect_ratio = width / height
    x_range = 4.0 / zoom
    y_range = x_range / aspect_ratio
    
    x_min = x_center - x_range / 2
    y_min = y_center - y_range / 2
    
    # Select color function
    if color_scheme == "fire":
        get_col = get_color_fire
    elif color_scheme == "psychedelic":
        get_col = get_color_psychedelic
    else:
        get_col = get_color
    
    for y in range(height):
        row = []
        c_imag = y_min + (y / height) * y_range
        
        for x in range(width):
            c_real = x_min + (x / width) * x_range
            
            if fractal_type == "mandelbrot":
                iterations = mandelbrot(c_real, c_imag, max_iter)
            elif fractal_type == "julia":
                iterations = julia(c_real, c_imag, julia_c[0], julia_c[1], max_iter)
            elif fractal_type == "burning_ship":
                iterations = burning_ship(c_real, c_imag, max_iter)
            else:
                iterations = 0
            
            row.append(get_col(iterations, max_iter))
        
        pixels.append(row)
        
        # Progress indicator
        if y % 100 == 0:
            print(f"Rendering: {100 * y // height}%", file=sys.stderr)
    
    print("Rendering: 100%", file=sys.stderr)
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
    
    print(f"Saved to {filename}", file=sys.stderr)


def print_usage():
    print("Usage: fractol.py <fractal> [options] [output.ppm]")
    print()
    print("Fractals:")
    print("  mandelbrot    - Mandelbrot set")
    print("  julia         - Julia set")
    print("  burning_ship  - Burning Ship fractal")
    print()
    print("Options:")
    print("  -w WIDTH      - Image width (default: 800)")
    print("  -h HEIGHT     - Image height (default: 600)")
    print("  -x CENTER_X   - X center coordinate (default: 0)")
    print("  -y CENTER_Y   - Y center coordinate (default: 0)")
    print("  -z ZOOM       - Zoom level (default: 1)")
    print("  -i MAX_ITER   - Maximum iterations (default: 100)")
    print("  -c SCHEME     - Color scheme: default, fire, psychedelic")
    print("  -jr JC_REAL   - Julia constant real part (default: -0.7)")
    print("  -ji JC_IMAG   - Julia constant imaginary part (default: 0.27015)")
    print()
    print("Examples:")
    print("  ./fractol.py mandelbrot output.ppm")
    print("  ./fractol.py julia -z 2 -c fire julia.ppm")
    print("  ./fractol.py mandelbrot -x -0.75 -y 0.1 -z 100 zoom.ppm")


def main():
    if len(sys.argv) < 2:
        print_usage()
        return
    
    fractal_type = sys.argv[1].lower()
    
    if fractal_type not in ["mandelbrot", "julia", "burning_ship"]:
        print_usage()
        return
    
    # Default parameters
    width = 800
    height = 600
    x_center = 0.0
    y_center = 0.0
    zoom = 1.0
    max_iter = 100
    color_scheme = "default"
    julia_real = -0.7
    julia_imag = 0.27015
    output_file = f"{fractal_type}.ppm"
    
    # Parse arguments
    i = 2
    while i < len(sys.argv):
        arg = sys.argv[i]
        if arg == "-w" and i + 1 < len(sys.argv):
            width = int(sys.argv[i + 1])
            i += 2
        elif arg == "-h" and i + 1 < len(sys.argv):
            height = int(sys.argv[i + 1])
            i += 2
        elif arg == "-x" and i + 1 < len(sys.argv):
            x_center = float(sys.argv[i + 1])
            i += 2
        elif arg == "-y" and i + 1 < len(sys.argv):
            y_center = float(sys.argv[i + 1])
            i += 2
        elif arg == "-z" and i + 1 < len(sys.argv):
            zoom = float(sys.argv[i + 1])
            i += 2
        elif arg == "-i" and i + 1 < len(sys.argv):
            max_iter = int(sys.argv[i + 1])
            i += 2
        elif arg == "-c" and i + 1 < len(sys.argv):
            color_scheme = sys.argv[i + 1]
            i += 2
        elif arg == "-jr" and i + 1 < len(sys.argv):
            julia_real = float(sys.argv[i + 1])
            i += 2
        elif arg == "-ji" and i + 1 < len(sys.argv):
            julia_imag = float(sys.argv[i + 1])
            i += 2
        elif arg.endswith(".ppm"):
            output_file = arg
            i += 1
        else:
            i += 1
    
    # Render and save
    pixels = render_fractal(
        fractal_type, width, height,
        x_center, y_center, zoom,
        max_iter, color_scheme,
        (julia_real, julia_imag)
    )
    
    write_ppm(output_file, pixels)


if __name__ == "__main__":
    main()
