#!/usr/bin/env python3
"""
Bomberman - Classic arcade game
Place bombs to destroy blocks and enemies
"""

import sys
import random
import time
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass, field


@dataclass
class Entity:
    x: int
    y: int
    symbol: str


@dataclass
class Bomb:
    x: int
    y: int
    timer: int = 3
    power: int = 2


@dataclass
class Player(Entity):
    bombs: int = 1
    power: int = 2
    alive: bool = True


@dataclass
class Enemy(Entity):
    direction: Tuple[int, int] = (1, 0)


class BombermanGame:
    """Bomberman game logic."""

    WALL = '#'
    BLOCK = 'X'
    EMPTY = ' '
    PLAYER = 'P'
    ENEMY = 'E'
    BOMB = 'B'
    EXPLOSION = '*'
    POWERUP_BOMB = 'b'
    POWERUP_POWER = 'p'

    def __init__(self, width: int = 15, height: int = 11):
        self.width = width
        self.height = height
        self.grid: List[List[str]] = []
        self.player: Optional[Player] = None
        self.enemies: List[Enemy] = []
        self.bombs: List[Bomb] = []
        self.explosions: Set[Tuple[int, int]] = set()
        self.score = 0
        self.game_over = False
        self.won = False
        self.tick = 0
        self._generate_map()

    def _generate_map(self):
        """Generate game map."""
        self.grid = [[self.EMPTY for _ in range(self.width)] for _ in range(self.height)]

        # Add walls (fixed pattern)
        for y in range(self.height):
            for x in range(self.width):
                # Border walls
                if x == 0 or x == self.width - 1 or y == 0 or y == self.height - 1:
                    self.grid[y][x] = self.WALL
                # Inner walls (every other cell)
                elif x % 2 == 0 and y % 2 == 0:
                    self.grid[y][x] = self.WALL

        # Add destructible blocks
        for y in range(1, self.height - 1):
            for x in range(1, self.width - 1):
                if self.grid[y][x] == self.EMPTY:
                    # Keep corners clear for player and enemies
                    if (x <= 2 and y <= 2) or (x >= self.width - 3 and y >= self.height - 3):
                        continue
                    if random.random() < 0.5:
                        self.grid[y][x] = self.BLOCK

        # Place player
        self.player = Player(1, 1, self.PLAYER)

        # Place enemies
        enemy_positions = [
            (self.width - 2, self.height - 2),
            (1, self.height - 2),
            (self.width - 2, 1)
        ]
        for x, y in enemy_positions:
            if self.grid[y][x] == self.EMPTY:
                self.enemies.append(Enemy(x, y, self.ENEMY))

    def move_player(self, dx: int, dy: int):
        """Move player."""
        if self.game_over or not self.player.alive:
            return

        new_x = self.player.x + dx
        new_y = self.player.y + dy

        if self._can_move(new_x, new_y):
            self.player.x = new_x
            self.player.y = new_y

            # Check powerups
            cell = self.grid[new_y][new_x]
            if cell == self.POWERUP_BOMB:
                self.player.bombs += 1
                self.grid[new_y][new_x] = self.EMPTY
            elif cell == self.POWERUP_POWER:
                self.player.power += 1
                self.grid[new_y][new_x] = self.EMPTY

    def _can_move(self, x: int, y: int) -> bool:
        """Check if position is walkable."""
        if not (0 <= x < self.width and 0 <= y < self.height):
            return False
        cell = self.grid[y][x]
        return cell not in [self.WALL, self.BLOCK, self.BOMB]

    def place_bomb(self):
        """Place a bomb at player position."""
        if self.game_over or not self.player.alive:
            return

        # Check if player has bombs available
        active_bombs = sum(1 for b in self.bombs)
        if active_bombs >= self.player.bombs:
            return

        # Check if bomb already at position
        for bomb in self.bombs:
            if bomb.x == self.player.x and bomb.y == self.player.y:
                return

        self.bombs.append(Bomb(self.player.x, self.player.y, timer=3, power=self.player.power))

    def update(self):
        """Update game state."""
        if self.game_over:
            return

        self.tick += 1
        self.explosions.clear()

        # Update bombs
        exploded = []
        for bomb in self.bombs:
            bomb.timer -= 1
            if bomb.timer <= 0:
                exploded.append(bomb)

        # Process explosions
        for bomb in exploded:
            self._explode(bomb)
            self.bombs.remove(bomb)

        # Move enemies
        if self.tick % 2 == 0:
            self._move_enemies()

        # Check collisions
        self._check_collisions()

        # Check win condition
        if not self.enemies:
            self.won = True
            self.game_over = True

    def _explode(self, bomb: Bomb):
        """Process bomb explosion."""
        directions = [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]

        for dx, dy in directions:
            for i in range(bomb.power + 1):
                x = bomb.x + dx * i
                y = bomb.y + dy * i

                if not (0 <= x < self.width and 0 <= y < self.height):
                    break

                cell = self.grid[y][x]

                if cell == self.WALL:
                    break

                self.explosions.add((x, y))

                if cell == self.BLOCK:
                    self.grid[y][x] = self.EMPTY
                    self.score += 10
                    # Chance to spawn powerup
                    if random.random() < 0.3:
                        self.grid[y][x] = random.choice([self.POWERUP_BOMB, self.POWERUP_POWER])
                    break

    def _move_enemies(self):
        """Move enemies."""
        for enemy in self.enemies:
            # Try current direction
            new_x = enemy.x + enemy.direction[0]
            new_y = enemy.y + enemy.direction[1]

            if self._can_move(new_x, new_y):
                enemy.x = new_x
                enemy.y = new_y
            else:
                # Change direction
                directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
                random.shuffle(directions)
                for d in directions:
                    if self._can_move(enemy.x + d[0], enemy.y + d[1]):
                        enemy.direction = d
                        break

    def _check_collisions(self):
        """Check for collisions."""
        # Player hit by explosion
        if (self.player.x, self.player.y) in self.explosions:
            self.player.alive = False
            self.game_over = True

        # Player touches enemy
        for enemy in self.enemies:
            if enemy.x == self.player.x and enemy.y == self.player.y:
                self.player.alive = False
                self.game_over = True

        # Enemies hit by explosion
        for enemy in self.enemies[:]:
            if (enemy.x, enemy.y) in self.explosions:
                self.enemies.remove(enemy)
                self.score += 100

    def render(self) -> str:
        """Render game as string."""
        lines = []
        lines.append(f"Bomberman - Score: {self.score}  Bombs: {self.player.bombs}  Power: {self.player.power}")
        lines.append("")

        for y in range(self.height):
            line = ""
            for x in range(self.width):
                # Check for entities at this position
                if (x, y) in self.explosions:
                    line += self.EXPLOSION
                elif self.player.alive and x == self.player.x and y == self.player.y:
                    line += self.PLAYER
                elif any(e.x == x and e.y == y for e in self.enemies):
                    line += self.ENEMY
                elif any(b.x == x and b.y == y for b in self.bombs):
                    # Show timer
                    bomb = next(b for b in self.bombs if b.x == x and b.y == y)
                    line += str(bomb.timer)
                else:
                    line += self.grid[y][x]
            lines.append(line)

        if self.game_over:
            if self.won:
                lines.append("\n🎉 YOU WIN!")
            else:
                lines.append("\n💥 GAME OVER!")

        return "\n".join(lines)


def play_interactive():
    """Play with keyboard."""
    try:
        import curses
    except ImportError:
        print("Curses not available. Running demo.")
        play_demo()
        return

    def main(stdscr):
        curses.curs_set(0)
        stdscr.nodelay(True)
        stdscr.timeout(200)

        game = BombermanGame()

        while not game.game_over:
            try:
                key = stdscr.getch()
                if key == ord('q'):
                    break
                elif key == curses.KEY_UP or key == ord('w'):
                    game.move_player(0, -1)
                elif key == curses.KEY_DOWN or key == ord('s'):
                    game.move_player(0, 1)
                elif key == curses.KEY_LEFT or key == ord('a'):
                    game.move_player(-1, 0)
                elif key == curses.KEY_RIGHT or key == ord('d'):
                    game.move_player(1, 0)
                elif key == ord(' '):
                    game.place_bomb()
            except:
                pass

            game.update()

            stdscr.clear()
            for i, line in enumerate(game.render().split('\n')):
                try:
                    stdscr.addstr(i, 0, line)
                except:
                    pass
            stdscr.addstr(15, 0, "WASD: Move, Space: Bomb, Q: Quit")
            stdscr.refresh()

        stdscr.nodelay(False)
        stdscr.addstr(17, 0, "Press any key...")
        stdscr.getch()

    curses.wrapper(main)


def play_demo():
    """Run automated demo."""
    print("Bomberman Demo")
    print("=" * 30)

    game = BombermanGame(13, 9)

    for _ in range(30):
        print("\033[H\033[J")
        print(game.render())

        if game.game_over:
            break

        # Simple AI
        action = random.choice(['up', 'down', 'left', 'right', 'bomb', 'wait'])
        if action == 'up':
            game.move_player(0, -1)
        elif action == 'down':
            game.move_player(0, 1)
        elif action == 'left':
            game.move_player(-1, 0)
        elif action == 'right':
            game.move_player(1, 0)
        elif action == 'bomb':
            game.place_bomb()

        game.update()
        time.sleep(0.3)

    print(f"\nFinal Score: {game.score}")


def main():
    if len(sys.argv) > 1 and sys.argv[1] == '--demo':
        play_demo()
    else:
        play_interactive()


if __name__ == "__main__":
    main()
