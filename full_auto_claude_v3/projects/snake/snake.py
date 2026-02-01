#!/usr/bin/env python3
"""
Snake - Classic snake game
Terminal-based implementation
"""

import sys
import random
import time
from typing import List, Tuple


class SnakeGame:
    """Snake game logic."""

    def __init__(self, width: int = 30, height: int = 15):
        self.width = width
        self.height = height
        self.snake: List[Tuple[int, int]] = []
        self.direction = (1, 0)  # Right
        self.food: Tuple[int, int] = (0, 0)
        self.score = 0
        self.game_over = False
        self.reset()

    def reset(self):
        """Reset game state."""
        cx, cy = self.width // 2, self.height // 2
        self.snake = [(cx, cy), (cx - 1, cy), (cx - 2, cy)]
        self.direction = (1, 0)
        self.score = 0
        self.game_over = False
        self._spawn_food()

    def _spawn_food(self):
        """Spawn food at random location."""
        while True:
            x = random.randint(0, self.width - 1)
            y = random.randint(0, self.height - 1)
            if (x, y) not in self.snake:
                self.food = (x, y)
                break

    def set_direction(self, dx: int, dy: int):
        """Set snake direction (prevents 180 degree turns)."""
        if (dx, dy) != (-self.direction[0], -self.direction[1]):
            self.direction = (dx, dy)

    def update(self):
        """Update game state."""
        if self.game_over:
            return

        # Calculate new head position
        head = self.snake[0]
        new_head = (
            (head[0] + self.direction[0]) % self.width,
            (head[1] + self.direction[1]) % self.height
        )

        # Check self collision
        if new_head in self.snake:
            self.game_over = True
            return

        # Move snake
        self.snake.insert(0, new_head)

        # Check food
        if new_head == self.food:
            self.score += 10
            self._spawn_food()
        else:
            self.snake.pop()

    def render(self) -> str:
        """Render game as string."""
        lines = []

        # Header
        lines.append(f"Snake Game - Score: {self.score}")
        lines.append("")

        # Top border
        lines.append("┌" + "─" * (self.width * 2) + "┐")

        # Game area
        for y in range(self.height):
            line = "│"
            for x in range(self.width):
                pos = (x, y)
                if pos == self.snake[0]:
                    line += "██"  # Head
                elif pos in self.snake:
                    line += "▓▓"  # Body
                elif pos == self.food:
                    line += "●●"  # Food
                else:
                    line += "  "
            line += "│"
            lines.append(line)

        # Bottom border
        lines.append("└" + "─" * (self.width * 2) + "┘")

        if self.game_over:
            lines.append("")
            lines.append("GAME OVER! Press R to restart, Q to quit")

        return "\n".join(lines)


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

        game = SnakeGame(30, 15)
        last_update = time.time()
        update_interval = 0.15

        while True:
            # Handle input
            try:
                key = stdscr.getch()
                if key == ord('q') or key == ord('Q'):
                    break
                elif key == ord('r') or key == ord('R'):
                    game.reset()
                elif key == curses.KEY_UP or key == ord('w'):
                    game.set_direction(0, -1)
                elif key == curses.KEY_DOWN or key == ord('s'):
                    game.set_direction(0, 1)
                elif key == curses.KEY_LEFT or key == ord('a'):
                    game.set_direction(-1, 0)
                elif key == curses.KEY_RIGHT or key == ord('d'):
                    game.set_direction(1, 0)
            except:
                pass

            # Update
            now = time.time()
            if now - last_update > update_interval:
                game.update()
                last_update = now
                # Speed up as score increases
                update_interval = max(0.05, 0.15 - game.score * 0.001)

            # Render
            stdscr.clear()
            for i, line in enumerate(game.render().split('\n')):
                try:
                    stdscr.addstr(i, 0, line)
                except:
                    pass
            stdscr.addstr(20, 0, "Controls: WASD or Arrows, Q quit, R restart")
            stdscr.refresh()

    curses.wrapper(main)


def play_demo():
    """Run automated demo."""
    print("Snake Demo Mode")
    print("=" * 30)

    game = SnakeGame(20, 10)

    for _ in range(50):
        print("\033[H\033[J")  # Clear screen
        print(game.render())

        if game.game_over:
            break

        # Simple AI: move towards food
        head = game.snake[0]
        fx, fy = game.food

        # Calculate desired direction
        dx = 1 if fx > head[0] else (-1 if fx < head[0] else 0)
        dy = 1 if fy > head[1] else (-1 if fy < head[1] else 0)

        # Prefer horizontal or vertical based on distance
        if abs(fx - head[0]) > abs(fy - head[1]):
            if dx != 0:
                game.set_direction(dx, 0)
            elif dy != 0:
                game.set_direction(0, dy)
        else:
            if dy != 0:
                game.set_direction(0, dy)
            elif dx != 0:
                game.set_direction(dx, 0)

        game.update()
        time.sleep(0.15)

    print(f"\nFinal Score: {game.score}")


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--demo':
            play_demo()
        elif sys.argv[1] == '--help':
            print("Snake Game")
            print("\nUsage:")
            print("  python snake.py        - Play game")
            print("  python snake.py --demo - Watch demo")
            print("\nControls:")
            print("  W/↑  Move up")
            print("  S/↓  Move down")
            print("  A/←  Move left")
            print("  D/→  Move right")
            print("  R    Restart")
            print("  Q    Quit")
        else:
            print(f"Unknown option: {sys.argv[1]}")
    else:
        play_interactive()


if __name__ == "__main__":
    main()
