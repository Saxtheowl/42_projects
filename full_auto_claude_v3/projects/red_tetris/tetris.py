#!/usr/bin/env python3
"""
Red Tetris - Classic Tetris game
Terminal-based implementation with curses
"""

import sys
import random
import time
from typing import List, Tuple, Optional


# Tetromino shapes
SHAPES = {
    'I': [[(0, 0), (0, 1), (0, 2), (0, 3)],
          [(0, 0), (1, 0), (2, 0), (3, 0)]],
    'O': [[(0, 0), (0, 1), (1, 0), (1, 1)]],
    'T': [[(0, 0), (0, 1), (0, 2), (1, 1)],
          [(0, 0), (1, 0), (2, 0), (1, 1)],
          [(0, 1), (1, 0), (1, 1), (1, 2)],
          [(0, 1), (1, 0), (1, 1), (2, 1)]],
    'S': [[(0, 1), (0, 2), (1, 0), (1, 1)],
          [(0, 0), (1, 0), (1, 1), (2, 1)]],
    'Z': [[(0, 0), (0, 1), (1, 1), (1, 2)],
          [(0, 1), (1, 0), (1, 1), (2, 0)]],
    'J': [[(0, 0), (1, 0), (1, 1), (1, 2)],
          [(0, 0), (0, 1), (1, 0), (2, 0)],
          [(0, 0), (0, 1), (0, 2), (1, 2)],
          [(0, 1), (1, 1), (2, 0), (2, 1)]],
    'L': [[(0, 2), (1, 0), (1, 1), (1, 2)],
          [(0, 0), (1, 0), (2, 0), (2, 1)],
          [(0, 0), (0, 1), (0, 2), (1, 0)],
          [(0, 0), (0, 1), (1, 1), (2, 1)]]
}

COLORS = {
    'I': '\033[96m',  # Cyan
    'O': '\033[93m',  # Yellow
    'T': '\033[95m',  # Magenta
    'S': '\033[92m',  # Green
    'Z': '\033[91m',  # Red
    'J': '\033[94m',  # Blue
    'L': '\033[38;5;208m',  # Orange
}
RESET = '\033[0m'


class Tetromino:
    """A Tetris piece."""

    def __init__(self, shape_type: str):
        self.type = shape_type
        self.rotations = SHAPES[shape_type]
        self.rotation = 0
        self.row = 0
        self.col = 3  # Start in middle

    @property
    def blocks(self) -> List[Tuple[int, int]]:
        """Get current block positions."""
        return [(self.row + r, self.col + c)
                for r, c in self.rotations[self.rotation]]

    def rotate(self, clockwise: bool = True):
        """Rotate the piece."""
        if clockwise:
            self.rotation = (self.rotation + 1) % len(self.rotations)
        else:
            self.rotation = (self.rotation - 1) % len(self.rotations)

    def move(self, dr: int, dc: int):
        """Move the piece."""
        self.row += dr
        self.col += dc


class TetrisGame:
    """Tetris game logic."""

    WIDTH = 10
    HEIGHT = 20

    def __init__(self):
        self.board: List[List[Optional[str]]] = [
            [None for _ in range(self.WIDTH)]
            for _ in range(self.HEIGHT)
        ]
        self.current: Optional[Tetromino] = None
        self.next_piece: Optional[Tetromino] = None
        self.score = 0
        self.level = 1
        self.lines = 0
        self.game_over = False

        self._spawn_piece()

    def _spawn_piece(self):
        """Spawn a new piece."""
        if self.next_piece:
            self.current = self.next_piece
        else:
            self.current = Tetromino(random.choice(list(SHAPES.keys())))

        self.next_piece = Tetromino(random.choice(list(SHAPES.keys())))

        # Check game over
        if not self._valid_position(self.current):
            self.game_over = True

    def _valid_position(self, piece: Tetromino) -> bool:
        """Check if piece position is valid."""
        for row, col in piece.blocks:
            if col < 0 or col >= self.WIDTH:
                return False
            if row >= self.HEIGHT:
                return False
            if row >= 0 and self.board[row][col] is not None:
                return False
        return True

    def move_left(self) -> bool:
        """Move piece left."""
        if not self.current:
            return False
        self.current.move(0, -1)
        if not self._valid_position(self.current):
            self.current.move(0, 1)
            return False
        return True

    def move_right(self) -> bool:
        """Move piece right."""
        if not self.current:
            return False
        self.current.move(0, 1)
        if not self._valid_position(self.current):
            self.current.move(0, -1)
            return False
        return True

    def move_down(self) -> bool:
        """Move piece down."""
        if not self.current:
            return False
        self.current.move(1, 0)
        if not self._valid_position(self.current):
            self.current.move(-1, 0)
            self._lock_piece()
            return False
        return True

    def hard_drop(self):
        """Drop piece to bottom."""
        if not self.current:
            return
        while self.move_down():
            self.score += 2
        self.score -= 2  # Remove last increment

    def rotate(self, clockwise: bool = True):
        """Rotate piece."""
        if not self.current:
            return
        self.current.rotate(clockwise)
        if not self._valid_position(self.current):
            # Wall kick - try moving left/right
            self.current.move(0, 1)
            if not self._valid_position(self.current):
                self.current.move(0, -2)
                if not self._valid_position(self.current):
                    self.current.move(0, 1)
                    self.current.rotate(not clockwise)

    def _lock_piece(self):
        """Lock current piece to board."""
        if not self.current:
            return

        for row, col in self.current.blocks:
            if 0 <= row < self.HEIGHT and 0 <= col < self.WIDTH:
                self.board[row][col] = self.current.type

        self._clear_lines()
        self._spawn_piece()

    def _clear_lines(self):
        """Clear completed lines."""
        lines_cleared = 0
        row = self.HEIGHT - 1

        while row >= 0:
            if all(cell is not None for cell in self.board[row]):
                # Remove line
                del self.board[row]
                self.board.insert(0, [None for _ in range(self.WIDTH)])
                lines_cleared += 1
            else:
                row -= 1

        if lines_cleared:
            self.lines += lines_cleared
            # Scoring: 40, 100, 300, 1200 for 1, 2, 3, 4 lines
            scores = {1: 40, 2: 100, 3: 300, 4: 1200}
            self.score += scores.get(lines_cleared, 0) * self.level

            # Level up every 10 lines
            self.level = self.lines // 10 + 1

    def tick(self):
        """Game tick - piece falls."""
        if not self.game_over:
            self.move_down()

    def render(self) -> str:
        """Render game state as string."""
        lines = []

        # Header
        lines.append(f"Score: {self.score}  Level: {self.level}  Lines: {self.lines}")
        lines.append("")

        # Create display board
        display = [[self.board[r][c] for c in range(self.WIDTH)]
                   for r in range(self.HEIGHT)]

        # Add current piece
        if self.current and not self.game_over:
            for row, col in self.current.blocks:
                if 0 <= row < self.HEIGHT and 0 <= col < self.WIDTH:
                    display[row][col] = self.current.type

        # Render board
        lines.append("┌" + "──" * self.WIDTH + "┐")
        for row in display:
            line = "│"
            for cell in row:
                if cell:
                    line += COLORS.get(cell, '') + "██" + RESET
                else:
                    line += "  "
            line += "│"
            lines.append(line)
        lines.append("└" + "──" * self.WIDTH + "┘")

        # Next piece
        if self.next_piece:
            lines.append("")
            lines.append("Next:")
            next_display = [[' ' for _ in range(4)] for _ in range(4)]
            for r, c in self.next_piece.rotations[0]:
                next_display[r][c] = self.next_piece.type
            for row in next_display:
                line = ""
                for cell in row:
                    if cell != ' ':
                        line += COLORS.get(cell, '') + "██" + RESET
                    else:
                        line += "  "
                if line.strip():
                    lines.append(line)

        if self.game_over:
            lines.append("")
            lines.append("GAME OVER!")

        return "\n".join(lines)


def play_interactive():
    """Play with keyboard input (requires curses)."""
    try:
        import curses
    except ImportError:
        print("Curses not available. Running demo mode instead.")
        play_demo()
        return

    def main(stdscr):
        curses.curs_set(0)
        stdscr.nodelay(True)
        stdscr.timeout(100)

        game = TetrisGame()
        last_tick = time.time()
        tick_interval = 0.5

        while not game.game_over:
            # Handle input
            try:
                key = stdscr.getch()
                if key == ord('q'):
                    break
                elif key == curses.KEY_LEFT or key == ord('a'):
                    game.move_left()
                elif key == curses.KEY_RIGHT or key == ord('d'):
                    game.move_right()
                elif key == curses.KEY_DOWN or key == ord('s'):
                    game.move_down()
                elif key == curses.KEY_UP or key == ord('w'):
                    game.rotate()
                elif key == ord(' '):
                    game.hard_drop()
            except:
                pass

            # Game tick
            now = time.time()
            if now - last_tick > tick_interval:
                game.tick()
                last_tick = now
                # Speed up with level
                tick_interval = max(0.1, 0.5 - (game.level - 1) * 0.05)

            # Render
            stdscr.clear()
            for i, line in enumerate(game.render().split('\n')):
                try:
                    stdscr.addstr(i, 0, line)
                except:
                    pass
            stdscr.addstr(25, 0, "Controls: ←→ Move, ↑ Rotate, ↓ Down, Space Drop, Q Quit")
            stdscr.refresh()

        # Show final score
        stdscr.nodelay(False)
        stdscr.addstr(27, 0, f"Final Score: {game.score}")
        stdscr.addstr(28, 0, "Press any key to exit...")
        stdscr.getch()

    curses.wrapper(main)


def play_demo():
    """Run automated demo."""
    print("Tetris Demo Mode")
    print("=" * 30)

    game = TetrisGame()

    for _ in range(50):  # 50 ticks
        print("\033[H\033[J")  # Clear screen
        print(game.render())

        if game.game_over:
            break

        # Random AI moves
        action = random.choice(['left', 'right', 'down', 'rotate', 'drop', 'none'])
        if action == 'left':
            game.move_left()
        elif action == 'right':
            game.move_right()
        elif action == 'down':
            game.move_down()
        elif action == 'rotate':
            game.rotate()
        elif action == 'drop':
            game.hard_drop()

        game.tick()
        time.sleep(0.1)

    print("\nFinal Score:", game.score)
    print("Lines Cleared:", game.lines)
    print("Level:", game.level)


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--demo':
            play_demo()
        elif sys.argv[1] == '--help':
            print("Red Tetris")
            print("\nUsage:")
            print("  python tetris.py        - Play interactive game")
            print("  python tetris.py --demo - Watch demo")
            print("\nControls:")
            print("  ← / A   Move left")
            print("  → / D   Move right")
            print("  ↓ / S   Move down")
            print("  ↑ / W   Rotate")
            print("  Space   Hard drop")
            print("  Q       Quit")
        else:
            print(f"Unknown option: {sys.argv[1]}")
    else:
        play_interactive()


if __name__ == "__main__":
    main()
