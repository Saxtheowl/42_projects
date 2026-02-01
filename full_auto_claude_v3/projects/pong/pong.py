#!/usr/bin/env python3
"""
Pong - Classic arcade game
Terminal-based implementation
"""

import sys
import time
import random
from dataclasses import dataclass


@dataclass
class Paddle:
    x: int
    y: int
    height: int = 4

    def move(self, dy: int, max_y: int):
        self.y = max(0, min(max_y - self.height, self.y + dy))


@dataclass
class Ball:
    x: float
    y: float
    dx: float = 1.0
    dy: float = 0.5


class PongGame:
    """Pong game logic."""

    def __init__(self, width: int = 60, height: int = 20):
        self.width = width
        self.height = height
        self.paddle1 = Paddle(1, height // 2 - 2)
        self.paddle2 = Paddle(width - 2, height // 2 - 2)
        self.ball = Ball(width // 2, height // 2)
        self.score1 = 0
        self.score2 = 0
        self.game_over = False
        self.winning_score = 5

    def reset_ball(self):
        """Reset ball to center."""
        self.ball.x = self.width // 2
        self.ball.y = self.height // 2
        self.ball.dx = random.choice([-1, 1])
        self.ball.dy = random.uniform(-0.5, 0.5)

    def update(self):
        """Update game state."""
        if self.game_over:
            return

        # Move ball
        self.ball.x += self.ball.dx
        self.ball.y += self.ball.dy

        # Wall collision (top/bottom)
        if self.ball.y <= 0 or self.ball.y >= self.height - 1:
            self.ball.dy = -self.ball.dy
            self.ball.y = max(0, min(self.height - 1, self.ball.y))

        # Paddle collision
        ball_x = int(self.ball.x)
        ball_y = int(self.ball.y)

        # Left paddle
        if ball_x <= self.paddle1.x + 1 and self.ball.dx < 0:
            if self.paddle1.y <= ball_y < self.paddle1.y + self.paddle1.height:
                self.ball.dx = abs(self.ball.dx) * 1.1  # Speed up
                # Add spin based on where ball hits paddle
                relative_y = (ball_y - self.paddle1.y) / self.paddle1.height - 0.5
                self.ball.dy += relative_y

        # Right paddle
        if ball_x >= self.paddle2.x - 1 and self.ball.dx > 0:
            if self.paddle2.y <= ball_y < self.paddle2.y + self.paddle2.height:
                self.ball.dx = -abs(self.ball.dx) * 1.1
                relative_y = (ball_y - self.paddle2.y) / self.paddle2.height - 0.5
                self.ball.dy += relative_y

        # Scoring
        if self.ball.x <= 0:
            self.score2 += 1
            self.reset_ball()
        elif self.ball.x >= self.width - 1:
            self.score1 += 1
            self.reset_ball()

        # Check win
        if self.score1 >= self.winning_score or self.score2 >= self.winning_score:
            self.game_over = True

        # Limit ball speed
        max_speed = 2.0
        self.ball.dx = max(-max_speed, min(max_speed, self.ball.dx))
        self.ball.dy = max(-max_speed, min(max_speed, self.ball.dy))

    def ai_move(self):
        """Simple AI for paddle2."""
        target_y = int(self.ball.y) - self.paddle2.height // 2

        if self.paddle2.y < target_y:
            self.paddle2.move(1, self.height)
        elif self.paddle2.y > target_y:
            self.paddle2.move(-1, self.height)

    def render(self) -> str:
        """Render game as string."""
        lines = []

        # Header
        lines.append(f"Pong - Player: {self.score1}  AI: {self.score2}")
        lines.append("")

        # Top border
        lines.append("┌" + "─" * self.width + "┐")

        # Game area
        ball_x = int(self.ball.x)
        ball_y = int(self.ball.y)

        for y in range(self.height):
            line = "│"
            for x in range(self.width):
                # Ball
                if x == ball_x and y == ball_y:
                    line += "●"
                # Left paddle
                elif x == self.paddle1.x and self.paddle1.y <= y < self.paddle1.y + self.paddle1.height:
                    line += "█"
                # Right paddle
                elif x == self.paddle2.x and self.paddle2.y <= y < self.paddle2.y + self.paddle2.height:
                    line += "█"
                # Center line
                elif x == self.width // 2 and y % 2 == 0:
                    line += "┊"
                else:
                    line += " "
            line += "│"
            lines.append(line)

        # Bottom border
        lines.append("└" + "─" * self.width + "┘")

        if self.game_over:
            winner = "Player" if self.score1 > self.score2 else "AI"
            lines.append(f"\n{winner} wins!")

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
        stdscr.timeout(50)

        game = PongGame(50, 18)

        while not game.game_over:
            # Handle input
            try:
                key = stdscr.getch()
                if key == ord('q'):
                    break
                elif key == curses.KEY_UP or key == ord('w'):
                    game.paddle1.move(-1, game.height)
                elif key == curses.KEY_DOWN or key == ord('s'):
                    game.paddle1.move(1, game.height)
            except:
                pass

            # AI move
            game.ai_move()

            # Update
            game.update()

            # Render
            stdscr.clear()
            for i, line in enumerate(game.render().split('\n')):
                try:
                    stdscr.addstr(i, 0, line)
                except:
                    pass
            stdscr.addstr(23, 0, "Controls: W/S or Arrows, Q to quit")
            stdscr.refresh()

        # Show final screen
        stdscr.nodelay(False)
        stdscr.addstr(25, 0, "Press any key to exit...")
        stdscr.getch()

    curses.wrapper(main)


def play_demo():
    """Run automated demo."""
    print("Pong Demo Mode")
    print("=" * 30)

    game = PongGame(40, 12)

    for _ in range(100):
        print("\033[H\033[J")  # Clear screen
        print(game.render())

        if game.game_over:
            break

        # Simple AI for both paddles
        # Player 1 (left)
        target = int(game.ball.y) - game.paddle1.height // 2
        if game.paddle1.y < target:
            game.paddle1.move(1, game.height)
        elif game.paddle1.y > target:
            game.paddle1.move(-1, game.height)

        # Player 2 (right)
        game.ai_move()

        game.update()
        time.sleep(0.05)

    print(f"\nFinal Score: Player {game.score1} - {game.score2} AI")


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--demo':
            play_demo()
        elif sys.argv[1] == '--help':
            print("Pong Game")
            print("\nUsage:")
            print("  python pong.py        - Play game")
            print("  python pong.py --demo - Watch demo")
            print("\nControls:")
            print("  W/↑  Move paddle up")
            print("  S/↓  Move paddle down")
            print("  Q    Quit")
        else:
            print(f"Unknown option: {sys.argv[1]}")
    else:
        play_interactive()


if __name__ == "__main__":
    main()
