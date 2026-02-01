#!/usr/bin/env python3
"""
Game of Life - Conway's cellular automaton
Terminal-based implementation
"""

import sys
import time
import random
from typing import Set, Tuple


class GameOfLife:
    """Conway's Game of Life."""

    def __init__(self, width: int = 60, height: int = 25):
        self.width = width
        self.height = height
        self.cells: Set[Tuple[int, int]] = set()
        self.generation = 0

    def randomize(self, density: float = 0.3):
        """Randomly populate cells."""
        self.cells.clear()
        for y in range(self.height):
            for x in range(self.width):
                if random.random() < density:
                    self.cells.add((x, y))
        self.generation = 0

    def add_pattern(self, pattern: str, offset_x: int = 0, offset_y: int = 0):
        """Add a pattern to the grid."""
        patterns = {
            'glider': [(1, 0), (2, 1), (0, 2), (1, 2), (2, 2)],
            'blinker': [(0, 1), (1, 1), (2, 1)],
            'block': [(0, 0), (1, 0), (0, 1), (1, 1)],
            'beacon': [(0, 0), (1, 0), (0, 1), (3, 2), (2, 3), (3, 3)],
            'toad': [(1, 0), (2, 0), (3, 0), (0, 1), (1, 1), (2, 1)],
            'pulsar': [],
            'glider_gun': [
                (24, 0), (22, 1), (24, 1), (12, 2), (13, 2), (20, 2), (21, 2),
                (34, 2), (35, 2), (11, 3), (15, 3), (20, 3), (21, 3), (34, 3),
                (35, 3), (0, 4), (1, 4), (10, 4), (16, 4), (20, 4), (21, 4),
                (0, 5), (1, 5), (10, 5), (14, 5), (16, 5), (17, 5), (22, 5),
                (24, 5), (10, 6), (16, 6), (24, 6), (11, 7), (15, 7),
                (12, 8), (13, 8)
            ],
            'r_pentomino': [(1, 0), (2, 0), (0, 1), (1, 1), (1, 2)],
            'diehard': [(6, 0), (0, 1), (1, 1), (1, 2), (5, 2), (6, 2), (7, 2)],
            'acorn': [(1, 0), (3, 1), (0, 2), (1, 2), (4, 2), (5, 2), (6, 2)],
        }

        if pattern.lower() not in patterns:
            print(f"Unknown pattern: {pattern}")
            print(f"Available: {', '.join(patterns.keys())}")
            return

        for x, y in patterns[pattern.lower()]:
            self.cells.add((x + offset_x, y + offset_y))

    def count_neighbors(self, x: int, y: int) -> int:
        """Count live neighbors of a cell."""
        count = 0
        for dy in [-1, 0, 1]:
            for dx in [-1, 0, 1]:
                if dx == 0 and dy == 0:
                    continue
                nx = (x + dx) % self.width
                ny = (y + dy) % self.height
                if (nx, ny) in self.cells:
                    count += 1
        return count

    def step(self):
        """Advance one generation."""
        new_cells = set()

        # Check all cells that might change
        candidates = set()
        for x, y in self.cells:
            candidates.add((x, y))
            for dy in [-1, 0, 1]:
                for dx in [-1, 0, 1]:
                    candidates.add(((x + dx) % self.width, (y + dy) % self.height))

        for x, y in candidates:
            neighbors = self.count_neighbors(x, y)
            alive = (x, y) in self.cells

            # Rules:
            # 1. Any live cell with 2-3 neighbors survives
            # 2. Any dead cell with exactly 3 neighbors becomes alive
            if alive and neighbors in [2, 3]:
                new_cells.add((x, y))
            elif not alive and neighbors == 3:
                new_cells.add((x, y))

        self.cells = new_cells
        self.generation += 1

    def render(self) -> str:
        """Render as string."""
        lines = []

        # Header
        lines.append(f"Game of Life - Generation: {self.generation}  Cells: {len(self.cells)}")
        lines.append("")

        # Grid
        for y in range(self.height):
            line = ""
            for x in range(self.width):
                if (x, y) in self.cells:
                    line += "██"
                else:
                    line += "  "
            lines.append(line)

        return "\n".join(lines)

    def is_stable(self) -> bool:
        """Check if the simulation has stabilized (no cells)."""
        return len(self.cells) == 0


def play_interactive():
    """Play with keyboard input."""
    try:
        import curses
    except ImportError:
        print("Curses not available. Running demo mode.")
        play_demo()
        return

    def main(stdscr):
        curses.curs_set(0)
        stdscr.nodelay(True)
        stdscr.timeout(100)

        game = GameOfLife(40, 20)
        game.randomize(0.25)
        paused = False
        speed = 100  # ms per frame

        while True:
            # Handle input
            try:
                key = stdscr.getch()
                if key == ord('q'):
                    break
                elif key == ord(' '):
                    paused = not paused
                elif key == ord('r'):
                    game.randomize(0.25)
                elif key == ord('c'):
                    game.cells.clear()
                    game.generation = 0
                elif key == ord('g'):
                    game.add_pattern('glider', 5, 5)
                elif key == ord('b'):
                    game.add_pattern('glider_gun', 2, 2)
                elif key == ord('+'):
                    speed = max(10, speed - 20)
                    stdscr.timeout(speed)
                elif key == ord('-'):
                    speed = min(500, speed + 20)
                    stdscr.timeout(speed)
            except:
                pass

            if not paused:
                game.step()

            # Render
            stdscr.clear()
            for i, line in enumerate(game.render().split('\n')):
                try:
                    stdscr.addstr(i, 0, line[:curses.COLS-1])
                except:
                    pass
            status = "PAUSED" if paused else "RUNNING"
            stdscr.addstr(24, 0, f"[{status}] Space:pause R:random C:clear G:glider B:gun +/-:speed Q:quit")
            stdscr.refresh()

    curses.wrapper(main)


def play_demo():
    """Run automated demo."""
    print("Game of Life Demo")
    print("=" * 30)

    game = GameOfLife(50, 20)

    # Add some patterns
    game.add_pattern('glider', 5, 5)
    game.add_pattern('glider', 15, 5)
    game.add_pattern('blinker', 25, 10)
    game.add_pattern('block', 35, 8)
    game.add_pattern('r_pentomino', 20, 10)

    for _ in range(50):
        print("\033[H\033[J")  # Clear screen
        print(game.render())
        print("\nDemo mode - showing various patterns evolving")

        game.step()
        time.sleep(0.15)

        if game.is_stable():
            break

    print(f"\nFinal generation: {game.generation}")


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--demo':
            play_demo()
        elif sys.argv[1] == '--help':
            print("Game of Life - Conway's Cellular Automaton")
            print("\nUsage:")
            print("  python life.py        - Interactive mode")
            print("  python life.py --demo - Watch demo")
            print("\nControls:")
            print("  Space  Pause/resume")
            print("  R      Randomize")
            print("  C      Clear")
            print("  G      Add glider")
            print("  B      Add glider gun")
            print("  +/-    Speed up/down")
            print("  Q      Quit")
            print("\nPatterns: glider, blinker, block, beacon, toad,")
            print("          glider_gun, r_pentomino, diehard, acorn")
        else:
            print(f"Unknown option: {sys.argv[1]}")
    else:
        play_interactive()


if __name__ == "__main__":
    main()
