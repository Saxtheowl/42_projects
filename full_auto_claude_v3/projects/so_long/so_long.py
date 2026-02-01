#!/usr/bin/env python3
"""
so_long - 2D tile-based game
Player collects items and reaches exit, outputs to PPM
"""

import sys
from typing import List, Tuple, Optional


class Color:
    """RGB Color."""
    def __init__(self, r: int, g: int, b: int):
        self.r = r
        self.g = g
        self.b = b


# Tile colors
COLORS = {
    '0': Color(50, 50, 50),      # Empty (floor)
    '1': Color(100, 70, 40),     # Wall (brown)
    'C': Color(255, 215, 0),     # Collectible (gold)
    'E': Color(0, 200, 0),       # Exit (green)
    'P': Color(0, 100, 255),     # Player (blue)
}

TILE_SIZE = 32


class Map:
    """Game map."""

    def __init__(self):
        self.grid: List[List[str]] = []
        self.width = 0
        self.height = 0
        self.player_pos: Tuple[int, int] = (0, 0)
        self.collectibles = 0
        self.collected = 0
        self.exit_pos: Tuple[int, int] = (0, 0)
        self.moves = 0
        self.won = False

    def load(self, filename: str):
        """Load map from .ber file."""
        with open(filename, 'r') as f:
            lines = [line.rstrip('\n') for line in f.readlines()]

        self.height = len(lines)
        self.width = len(lines[0]) if lines else 0
        self.grid = [list(line.ljust(self.width)) for line in lines]

        # Find player, collectibles, exit
        for y in range(self.height):
            for x in range(self.width):
                cell = self.grid[y][x]
                if cell == 'P':
                    self.player_pos = (x, y)
                elif cell == 'C':
                    self.collectibles += 1
                elif cell == 'E':
                    self.exit_pos = (x, y)

    def validate(self) -> bool:
        """Validate map."""
        # Check rectangular
        for row in self.grid:
            if len(row) != self.width:
                print("Error: Map not rectangular")
                return False

        # Check walls
        for x in range(self.width):
            if self.grid[0][x] != '1' or self.grid[self.height-1][x] != '1':
                print("Error: Map not surrounded by walls")
                return False
        for y in range(self.height):
            if self.grid[y][0] != '1' or self.grid[y][self.width-1] != '1':
                print("Error: Map not surrounded by walls")
                return False

        # Check required elements
        if self.collectibles == 0:
            print("Error: No collectibles")
            return False

        return True

    def move_player(self, dx: int, dy: int) -> bool:
        """Move player."""
        if self.won:
            return False

        px, py = self.player_pos
        nx, ny = px + dx, py + dy

        # Check bounds
        if not (0 <= nx < self.width and 0 <= ny < self.height):
            return False

        # Check wall
        cell = self.grid[ny][nx]
        if cell == '1':
            return False

        # Check exit
        if cell == 'E':
            if self.collected == self.collectibles:
                self.won = True
                print(f"You won in {self.moves + 1} moves!")
            else:
                print(f"Collect all items first! ({self.collected}/{self.collectibles})")
                return False

        # Collect item
        if cell == 'C':
            self.collected += 1
            self.grid[ny][nx] = '0'
            print(f"Collected! ({self.collected}/{self.collectibles})")

        # Move
        self.grid[py][px] = '0'
        self.grid[ny][nx] = 'P'
        self.player_pos = (nx, ny)
        self.moves += 1

        return True


class Renderer:
    """PPM renderer for the game."""

    def __init__(self, tile_size: int = TILE_SIZE):
        self.tile_size = tile_size

    def render_tile(self, char: str) -> List[List[Color]]:
        """Render a single tile."""
        base_color = COLORS.get(char, COLORS['0'])
        tile = [[base_color for _ in range(self.tile_size)]
                for _ in range(self.tile_size)]

        # Add patterns
        if char == '1':  # Wall - brick pattern
            for y in range(self.tile_size):
                for x in range(self.tile_size):
                    if y % 8 == 0 or ((y // 8) % 2 == 0 and x % 16 == 0) or \
                       ((y // 8) % 2 == 1 and (x + 8) % 16 == 0):
                        tile[y][x] = Color(60, 40, 20)

        elif char == 'P':  # Player - simple face
            cx, cy = self.tile_size // 2, self.tile_size // 2
            for y in range(self.tile_size):
                for x in range(self.tile_size):
                    dist = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
                    if dist < self.tile_size // 3:
                        tile[y][x] = Color(255, 200, 150)  # Skin
                    # Eyes
                    if abs(x - cx + 5) < 3 and abs(y - cy - 4) < 3:
                        tile[y][x] = Color(0, 0, 0)
                    if abs(x - cx - 5) < 3 and abs(y - cy - 4) < 3:
                        tile[y][x] = Color(0, 0, 0)

        elif char == 'C':  # Collectible - coin
            cx, cy = self.tile_size // 2, self.tile_size // 2
            for y in range(self.tile_size):
                for x in range(self.tile_size):
                    dist = ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5
                    if dist < self.tile_size // 3:
                        if dist < self.tile_size // 4:
                            tile[y][x] = Color(255, 230, 100)
                        else:
                            tile[y][x] = Color(200, 160, 0)

        elif char == 'E':  # Exit - door
            for y in range(4, self.tile_size - 2):
                for x in range(6, self.tile_size - 6):
                    tile[y][x] = Color(139, 69, 19)  # Brown door
            # Door handle
            for y in range(self.tile_size // 2 - 2, self.tile_size // 2 + 2):
                for x in range(self.tile_size - 12, self.tile_size - 8):
                    tile[y][x] = Color(255, 215, 0)

        return tile

    def render(self, game_map: Map) -> List[List[Color]]:
        """Render full map."""
        img_width = game_map.width * self.tile_size
        img_height = game_map.height * self.tile_size

        image = [[Color(0, 0, 0) for _ in range(img_width)]
                for _ in range(img_height)]

        for my in range(game_map.height):
            for mx in range(game_map.width):
                tile = self.render_tile(game_map.grid[my][mx])

                for ty in range(self.tile_size):
                    for tx in range(self.tile_size):
                        py = my * self.tile_size + ty
                        px = mx * self.tile_size + tx
                        image[py][px] = tile[ty][tx]

        return image

    def save_ppm(self, filename: str, image: List[List[Color]]):
        """Save as PPM file."""
        height = len(image)
        width = len(image[0]) if image else 0

        with open(filename, 'wb') as f:
            f.write(f"P6\n{width} {height}\n255\n".encode())
            for row in image:
                for pixel in row:
                    f.write(bytes([pixel.r, pixel.g, pixel.b]))


def create_demo_map() -> str:
    """Create demo map."""
    content = """111111111111
1P0000000001
1000C000C001
1011111110E1
1C000000C001
111111111111"""
    filename = 'demo.ber'
    with open(filename, 'w') as f:
        f.write(content)
    return filename


def run_demo():
    """Run demo."""
    print("so_long Demo")
    print("=" * 40)

    # Create demo map
    map_file = create_demo_map()
    print(f"Created demo map: {map_file}")

    # Load map
    game_map = Map()
    game_map.load(map_file)

    if not game_map.validate():
        return

    print(f"Map size: {game_map.width}x{game_map.height}")
    print(f"Collectibles: {game_map.collectibles}")
    print(f"Player start: {game_map.player_pos}")
    print(f"Exit: {game_map.exit_pos}")

    # Render initial state
    renderer = Renderer()
    image = renderer.render(game_map)
    renderer.save_ppm('so_long_frame_0.ppm', image)
    print("\nRendered: so_long_frame_0.ppm")

    # Simulate some moves
    moves = [
        (1, 0),   # Right
        (1, 0),
        (1, 0),
        (0, 1),   # Down
        (0, 1),
        (-1, 0),  # Left
        (-1, 0),
        (-1, 0),
        (-1, 0),
        (0, -1),  # Up
        (1, 0),
        (1, 0),
        (1, 0),
        (1, 0),
        (0, 1),
        (0, 1),
        (1, 0),
        (1, 0),
        (1, 0),
    ]

    frame = 1
    for dx, dy in moves:
        if game_map.move_player(dx, dy):
            image = renderer.render(game_map)
            renderer.save_ppm(f'so_long_frame_{frame}.ppm', image)
            print(f"Move {frame}: pos={game_map.player_pos}, collected={game_map.collected}")
            frame += 1

        if game_map.won:
            break

    print(f"\nGenerated {frame} frames")
    print("View with: display so_long_frame_0.ppm")


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("so_long - 2D Tile Game")
        print("\nUsage:")
        print("  python so_long.py <map.ber>  - Render map to PPM")
        print("  python so_long.py --demo     - Run demo")
        print("\nMap format (.ber):")
        print("  1 - Wall")
        print("  0 - Empty floor")
        print("  C - Collectible")
        print("  E - Exit")
        print("  P - Player start")
        return

    if sys.argv[1] == '--demo':
        run_demo()
        return

    # Load and render map
    game_map = Map()
    try:
        game_map.load(sys.argv[1])
    except FileNotFoundError:
        print(f"Error: File not found: {sys.argv[1]}")
        return

    if not game_map.validate():
        return

    print(f"Loaded map: {game_map.width}x{game_map.height}")

    renderer = Renderer()
    image = renderer.render(game_map)
    output = 'so_long_render.ppm'
    renderer.save_ppm(output, image)
    print(f"Rendered to: {output}")


if __name__ == "__main__":
    main()
