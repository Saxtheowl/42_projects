#!/usr/bin/env python3
"""
cub3D - Raycasting engine inspired by Wolfenstein 3D
Renders 3D view from 2D map using raycasting, outputs to PPM file.
"""

import sys
import math
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class Vec2:
    x: float
    y: float


@dataclass
class Color:
    r: int
    g: int
    b: int

    @staticmethod
    def from_hex(h: int) -> 'Color':
        return Color((h >> 16) & 0xFF, (h >> 8) & 0xFF, h & 0xFF)


# Wall textures (simple patterns)
TEXTURES = {
    'N': [Color(180, 0, 0)] * 64,      # North - Red
    'S': [Color(0, 180, 0)] * 64,      # South - Green
    'E': [Color(0, 0, 180)] * 64,      # East - Blue
    'W': [Color(180, 180, 0)] * 64,    # West - Yellow
}


class Map:
    """Game map representation."""

    def __init__(self):
        self.grid: List[List[str]] = []
        self.width = 0
        self.height = 0
        self.ceiling_color = Color(100, 100, 200)  # Sky blue
        self.floor_color = Color(100, 80, 60)      # Brown

    def load(self, filename: str):
        """Load map from .cub file."""
        with open(filename, 'r') as f:
            lines = f.readlines()

        parsing_map = False
        map_lines = []

        for line in lines:
            line = line.rstrip('\n')

            if line.startswith('F '):
                # Floor color
                parts = line[2:].split(',')
                if len(parts) == 3:
                    self.floor_color = Color(int(parts[0]), int(parts[1]), int(parts[2]))
            elif line.startswith('C '):
                # Ceiling color
                parts = line[2:].split(',')
                if len(parts) == 3:
                    self.ceiling_color = Color(int(parts[0]), int(parts[1]), int(parts[2]))
            elif line.startswith('NO ') or line.startswith('SO ') or \
                 line.startswith('WE ') or line.startswith('EA '):
                # Texture paths (we use built-in colors)
                pass
            elif '1' in line:
                parsing_map = True
                map_lines.append(line)
            elif parsing_map and line.strip():
                map_lines.append(line)

        # Parse map
        self.height = len(map_lines)
        self.width = max(len(line) for line in map_lines) if map_lines else 0

        self.grid = []
        for line in map_lines:
            row = list(line.ljust(self.width))
            self.grid.append(row)

    def get(self, x: int, y: int) -> str:
        """Get cell at position, '1' for out of bounds."""
        if 0 <= y < self.height and 0 <= x < self.width:
            return self.grid[y][x]
        return '1'

    def is_wall(self, x: int, y: int) -> bool:
        """Check if position is a wall."""
        return self.get(x, y) == '1'

    def find_player(self) -> Tuple[float, float, float]:
        """Find player position and direction."""
        for y in range(self.height):
            for x in range(self.width):
                cell = self.grid[y][x]
                if cell in 'NSEW':
                    # Direction angles
                    angles = {'N': -math.pi/2, 'S': math.pi/2,
                             'E': 0, 'W': math.pi}
                    return x + 0.5, y + 0.5, angles[cell]
        return 1.5, 1.5, 0


class Player:
    """Player state."""

    def __init__(self, x: float, y: float, angle: float):
        self.x = x
        self.y = y
        self.angle = angle
        self.fov = math.pi / 3  # 60 degrees FOV

    def move(self, game_map: Map, forward: float, strafe: float):
        """Move player."""
        new_x = self.x + math.cos(self.angle) * forward - math.sin(self.angle) * strafe
        new_y = self.y + math.sin(self.angle) * forward + math.cos(self.angle) * strafe

        # Collision detection
        margin = 0.2
        if not game_map.is_wall(int(new_x - margin), int(self.y)) and \
           not game_map.is_wall(int(new_x + margin), int(self.y)):
            self.x = new_x
        if not game_map.is_wall(int(self.x), int(new_y - margin)) and \
           not game_map.is_wall(int(self.x), int(new_y + margin)):
            self.y = new_y

    def rotate(self, delta: float):
        """Rotate player."""
        self.angle += delta


class Raycaster:
    """Raycasting engine."""

    def __init__(self, width: int = 640, height: int = 480):
        self.width = width
        self.height = height
        self.framebuffer: List[List[Color]] = []

    def cast_ray(self, game_map: Map, px: float, py: float, angle: float) -> Tuple[float, str]:
        """Cast a ray and return distance and wall side."""
        # Ray direction
        ray_dx = math.cos(angle)
        ray_dy = math.sin(angle)

        # Current map position
        map_x = int(px)
        map_y = int(py)

        # Delta distance (distance to next x or y side)
        delta_x = abs(1 / ray_dx) if ray_dx != 0 else float('inf')
        delta_y = abs(1 / ray_dy) if ray_dy != 0 else float('inf')

        # Step direction and initial side distance
        if ray_dx < 0:
            step_x = -1
            side_x = (px - map_x) * delta_x
        else:
            step_x = 1
            side_x = (map_x + 1 - px) * delta_x

        if ray_dy < 0:
            step_y = -1
            side_y = (py - map_y) * delta_y
        else:
            step_y = 1
            side_y = (map_y + 1 - py) * delta_y

        # DDA algorithm
        side = 0  # 0 = x-side, 1 = y-side
        max_distance = 100.0

        while True:
            # Jump to next map square
            if side_x < side_y:
                side_x += delta_x
                map_x += step_x
                side = 0
            else:
                side_y += delta_y
                map_y += step_y
                side = 1

            # Check for wall hit
            if game_map.is_wall(map_x, map_y):
                break

            # Distance limit
            if side_x > max_distance and side_y > max_distance:
                return max_distance, 'N'

        # Calculate perpendicular distance (avoid fisheye)
        if side == 0:
            distance = side_x - delta_x
            wall_side = 'W' if step_x < 0 else 'E'
        else:
            distance = side_y - delta_y
            wall_side = 'N' if step_y < 0 else 'S'

        return max(0.001, distance), wall_side

    def render(self, game_map: Map, player: Player) -> List[List[Color]]:
        """Render the scene."""
        self.framebuffer = [[Color(0, 0, 0) for _ in range(self.width)]
                           for _ in range(self.height)]

        # Draw ceiling and floor
        for y in range(self.height // 2):
            for x in range(self.width):
                self.framebuffer[y][x] = game_map.ceiling_color
        for y in range(self.height // 2, self.height):
            for x in range(self.width):
                self.framebuffer[y][x] = game_map.floor_color

        # Cast rays for each column
        for x in range(self.width):
            # Calculate ray angle
            camera_x = 2 * x / self.width - 1  # -1 to 1
            ray_angle = player.angle + camera_x * player.fov / 2

            # Cast ray
            distance, wall_side = self.cast_ray(game_map, player.x, player.y, ray_angle)

            # Calculate wall height
            wall_height = int(self.height / distance) if distance > 0 else self.height

            # Calculate draw bounds
            draw_start = max(0, (self.height - wall_height) // 2)
            draw_end = min(self.height - 1, (self.height + wall_height) // 2)

            # Get wall color based on side
            base_color = TEXTURES[wall_side][0]

            # Apply distance shading
            shade = max(0.2, 1 - distance / 10)
            wall_color = Color(
                int(base_color.r * shade),
                int(base_color.g * shade),
                int(base_color.b * shade)
            )

            # Draw wall column
            for y in range(draw_start, draw_end + 1):
                self.framebuffer[y][x] = wall_color

        return self.framebuffer

    def render_minimap(self, game_map: Map, player: Player, scale: int = 8):
        """Render minimap overlay."""
        offset_x = 10
        offset_y = 10

        for my in range(game_map.height):
            for mx in range(game_map.width):
                cell = game_map.get(mx, my)

                if cell == '1':
                    color = Color(100, 100, 100)
                elif cell in 'NSEW0':
                    color = Color(50, 50, 50)
                else:
                    continue

                # Draw scaled cell
                for dy in range(scale):
                    for dx in range(scale):
                        py = offset_y + my * scale + dy
                        px = offset_x + mx * scale + dx
                        if 0 <= px < self.width and 0 <= py < self.height:
                            self.framebuffer[py][px] = color

        # Draw player
        px = int(offset_x + player.x * scale)
        py = int(offset_y + player.y * scale)
        for dy in range(-2, 3):
            for dx in range(-2, 3):
                if 0 <= px + dx < self.width and 0 <= py + dy < self.height:
                    self.framebuffer[py + dy][px + dx] = Color(255, 255, 0)

        # Draw direction
        dir_x = int(px + math.cos(player.angle) * scale)
        dir_y = int(py + math.sin(player.angle) * scale)
        if 0 <= dir_x < self.width and 0 <= dir_y < self.height:
            self.framebuffer[dir_y][dir_x] = Color(255, 0, 0)


def save_ppm(filename: str, framebuffer: List[List[Color]]):
    """Save framebuffer as PPM image."""
    height = len(framebuffer)
    width = len(framebuffer[0]) if framebuffer else 0

    with open(filename, 'wb') as f:
        f.write(f"P6\n{width} {height}\n255\n".encode())
        for row in framebuffer:
            for pixel in row:
                f.write(bytes([pixel.r, pixel.g, pixel.b]))


def create_demo_map() -> str:
    """Create a demo map file."""
    content = """NO ./textures/north.xpm
SO ./textures/south.xpm
WE ./textures/west.xpm
EA ./textures/east.xpm

F 100,80,60
C 100,100,200

111111111111111
100000000000001
100000000000001
100000100000001
100000100000001
100000100000001
100000000000001
100N00000000001
100000000000001
100000111110001
100000100010001
100000100010001
100000000010001
100000000000001
111111111111111
"""
    filename = 'demo.cub'
    with open(filename, 'w') as f:
        f.write(content)
    return filename


def run_demo():
    """Run demo rendering multiple frames."""
    # Create demo map
    map_file = create_demo_map()

    # Load map
    game_map = Map()
    game_map.load(map_file)

    # Find player
    px, py, angle = game_map.find_player()
    player = Player(px, py, angle)

    # Create raycaster
    raycaster = Raycaster(640, 480)

    print("cub3D Demo - Generating frames...")
    print(f"Map size: {game_map.width}x{game_map.height}")
    print(f"Player start: ({px:.2f}, {py:.2f}), angle: {math.degrees(angle):.1f}°")

    # Render multiple frames simulating movement
    frames = []
    for i in range(8):
        # Render frame
        framebuffer = raycaster.render(game_map, player)
        raycaster.render_minimap(game_map, player)

        # Save frame
        filename = f"frame_{i:03d}.ppm"
        save_ppm(filename, raycaster.framebuffer)
        frames.append(filename)

        print(f"  Frame {i}: pos=({player.x:.2f}, {player.y:.2f}), angle={math.degrees(player.angle):.1f}°")

        # Move forward and rotate
        player.move(game_map, 0.5, 0)
        player.rotate(math.pi / 8)

    print(f"\nGenerated {len(frames)} frames:")
    for f in frames:
        print(f"  - {f}")

    print("\nView with: display frame_000.ppm (ImageMagick)")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("cub3D - Raycasting Engine")
        print("\nUsage:")
        print("  python cub3d.py <map.cub>     - Render map to PPM")
        print("  python cub3d.py --demo        - Run demo")
        print("\nMap format (.cub):")
        print("  NO <path>    - North texture")
        print("  SO <path>    - South texture")
        print("  WE <path>    - West texture")
        print("  EA <path>    - East texture")
        print("  F R,G,B      - Floor color")
        print("  C R,G,B      - Ceiling color")
        print("  1            - Wall")
        print("  0            - Empty")
        print("  N/S/E/W      - Player start + direction")
        return

    if sys.argv[1] == '--demo':
        run_demo()
        return

    # Load map
    map_file = sys.argv[1]
    print(f"Loading map: {map_file}")

    game_map = Map()
    try:
        game_map.load(map_file)
    except FileNotFoundError:
        print(f"Error: Map file not found: {map_file}")
        return

    print(f"Map size: {game_map.width}x{game_map.height}")

    # Find player
    px, py, angle = game_map.find_player()
    player = Player(px, py, angle)
    print(f"Player: ({px:.2f}, {py:.2f}), facing: {math.degrees(angle):.1f}°")

    # Render
    raycaster = Raycaster(800, 600)
    raycaster.render(game_map, player)
    raycaster.render_minimap(game_map, player)

    # Save
    output = 'cub3d_render.ppm'
    save_ppm(output, raycaster.framebuffer)
    print(f"Rendered to: {output}")


if __name__ == "__main__":
    main()
