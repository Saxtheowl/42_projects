#!/usr/bin/env python3
"""
ft_shmup - Shoot 'em Up Game
Space shooter with enemies, bullets, and power-ups
"""

import sys
import os
import time
import random
import tty
import termios
import select
from dataclasses import dataclass, field
from typing import List, Optional
from enum import Enum


class EntityType(Enum):
    PLAYER = 1
    ENEMY = 2
    BULLET = 3
    ENEMY_BULLET = 4
    POWERUP = 5


@dataclass
class Entity:
    x: float
    y: float
    width: int
    height: int
    entity_type: EntityType
    hp: int = 1
    speed: float = 1.0
    sprite: List[str] = field(default_factory=list)
    active: bool = True


class Game:
    def __init__(self, width: int = 80, height: int = 24):
        self.width = width
        self.height = height
        self.player: Optional[Entity] = None
        self.entities: List[Entity] = []
        self.score = 0
        self.level = 1
        self.running = True
        self.game_over = False
        self.spawn_timer = 0
        self.powerup_timer = 0
        self.player_bullets = 1
        self.player_speed = 1.0

        self.init_player()

    def init_player(self):
        """Initialize player ship."""
        sprite = [
            "  /\\  ",
            " /||\\ ",
            "/====\\",
            "||  ||"
        ]
        self.player = Entity(
            x=self.width // 2 - 3,
            y=self.height - 6,
            width=6,
            height=4,
            entity_type=EntityType.PLAYER,
            hp=3,
            speed=2.0,
            sprite=sprite
        )

    def spawn_enemy(self):
        """Spawn a random enemy."""
        enemy_types = [
            # Basic enemy
            (["<-->", " \\/ "], 1, 1.0),
            # Medium enemy
            ([" /\\ ", "<##>", " \\/ "], 2, 0.8),
            # Heavy enemy
            (["/====\\", "|####|", "\\====/"], 3, 0.5),
        ]

        etype = random.choice(enemy_types)
        sprite, hp, speed = etype

        enemy = Entity(
            x=random.randint(0, self.width - len(sprite[0])),
            y=-len(sprite),
            width=len(sprite[0]),
            height=len(sprite),
            entity_type=EntityType.ENEMY,
            hp=hp,
            speed=speed + self.level * 0.1,
            sprite=sprite
        )
        self.entities.append(enemy)

    def spawn_powerup(self):
        """Spawn a power-up."""
        powerup_types = [
            ("[+]", "health"),  # Health
            ("[*]", "fire"),    # Extra fire
            ("[>]", "speed"),   # Speed
        ]

        ptype = random.choice(powerup_types)
        sprite, _ = ptype

        powerup = Entity(
            x=random.randint(0, self.width - 3),
            y=0,
            width=3,
            height=1,
            entity_type=EntityType.POWERUP,
            speed=0.5,
            sprite=[sprite]
        )
        self.entities.append(powerup)

    def player_shoot(self):
        """Player fires bullets."""
        if not self.player or not self.player.active:
            return

        for i in range(self.player_bullets):
            offset = (i - self.player_bullets // 2) * 2
            bullet = Entity(
                x=self.player.x + self.player.width // 2 + offset,
                y=self.player.y - 1,
                width=1,
                height=1,
                entity_type=EntityType.BULLET,
                speed=3.0,
                sprite=["|"]
            )
            self.entities.append(bullet)

    def enemy_shoot(self, enemy: Entity):
        """Enemy fires a bullet."""
        bullet = Entity(
            x=enemy.x + enemy.width // 2,
            y=enemy.y + enemy.height,
            width=1,
            height=1,
            entity_type=EntityType.ENEMY_BULLET,
            speed=2.0,
            sprite=["v"]
        )
        self.entities.append(bullet)

    def check_collision(self, e1: Entity, e2: Entity) -> bool:
        """Check if two entities collide."""
        return (e1.x < e2.x + e2.width and
                e1.x + e1.width > e2.x and
                e1.y < e2.y + e2.height and
                e1.y + e1.height > e2.y)

    def update(self):
        """Update game state."""
        if self.game_over:
            return

        # Spawn enemies
        self.spawn_timer += 1
        if self.spawn_timer >= max(30 - self.level * 2, 10):
            self.spawn_enemy()
            self.spawn_timer = 0

        # Spawn power-ups
        self.powerup_timer += 1
        if self.powerup_timer >= 200:
            self.spawn_powerup()
            self.powerup_timer = 0

        # Update entities
        for entity in self.entities[:]:
            if not entity.active:
                continue

            if entity.entity_type == EntityType.BULLET:
                entity.y -= entity.speed
                if entity.y < 0:
                    entity.active = False

            elif entity.entity_type == EntityType.ENEMY_BULLET:
                entity.y += entity.speed
                if entity.y > self.height:
                    entity.active = False

            elif entity.entity_type == EntityType.ENEMY:
                entity.y += entity.speed
                if entity.y > self.height:
                    entity.active = False
                # Random shooting
                if random.random() < 0.02:
                    self.enemy_shoot(entity)

            elif entity.entity_type == EntityType.POWERUP:
                entity.y += entity.speed
                if entity.y > self.height:
                    entity.active = False

        # Check collisions
        for entity in self.entities[:]:
            if not entity.active:
                continue

            # Player bullets vs enemies
            if entity.entity_type == EntityType.BULLET:
                for enemy in self.entities:
                    if enemy.entity_type == EntityType.ENEMY and enemy.active:
                        if self.check_collision(entity, enemy):
                            entity.active = False
                            enemy.hp -= 1
                            if enemy.hp <= 0:
                                enemy.active = False
                                self.score += 100
                            break

            # Enemy bullets vs player
            if entity.entity_type == EntityType.ENEMY_BULLET:
                if self.player and self.player.active:
                    if self.check_collision(entity, self.player):
                        entity.active = False
                        self.player.hp -= 1
                        if self.player.hp <= 0:
                            self.player.active = False
                            self.game_over = True

            # Enemies vs player
            if entity.entity_type == EntityType.ENEMY:
                if self.player and self.player.active:
                    if self.check_collision(entity, self.player):
                        entity.active = False
                        self.player.hp -= 1
                        if self.player.hp <= 0:
                            self.player.active = False
                            self.game_over = True

            # Power-ups vs player
            if entity.entity_type == EntityType.POWERUP:
                if self.player and self.player.active:
                    if self.check_collision(entity, self.player):
                        entity.active = False
                        # Random effect
                        effect = random.choice(["health", "fire", "speed"])
                        if effect == "health":
                            self.player.hp = min(self.player.hp + 1, 5)
                        elif effect == "fire":
                            self.player_bullets = min(self.player_bullets + 1, 5)
                        elif effect == "speed":
                            self.player_speed = min(self.player_speed + 0.5, 3.0)
                        self.score += 50

        # Remove inactive entities
        self.entities = [e for e in self.entities if e.active]

        # Level up
        if self.score >= self.level * 1000:
            self.level += 1

    def move_player(self, dx: int, dy: int):
        """Move player."""
        if not self.player or not self.player.active:
            return

        new_x = self.player.x + dx * self.player_speed
        new_y = self.player.y + dy * self.player_speed

        self.player.x = max(0, min(self.width - self.player.width, new_x))
        self.player.y = max(0, min(self.height - self.player.height, new_y))

    def render(self) -> str:
        """Render game to string."""
        # Create buffer
        buffer = [[' ' for _ in range(self.width)] for _ in range(self.height)]

        # Draw entities
        for entity in self.entities:
            if not entity.active:
                continue
            for row_idx, row in enumerate(entity.sprite):
                y = int(entity.y) + row_idx
                if 0 <= y < self.height:
                    for col_idx, char in enumerate(row):
                        x = int(entity.x) + col_idx
                        if 0 <= x < self.width and char != ' ':
                            buffer[y][x] = char

        # Draw player
        if self.player and self.player.active:
            for row_idx, row in enumerate(self.player.sprite):
                y = int(self.player.y) + row_idx
                if 0 <= y < self.height:
                    for col_idx, char in enumerate(row):
                        x = int(self.player.x) + col_idx
                        if 0 <= x < self.width and char != ' ':
                            buffer[y][x] = char

        # Build output
        lines = [''.join(row) for row in buffer]

        # Header
        hp = self.player.hp if self.player else 0
        header = f"Score: {self.score:06d} | Level: {self.level} | HP: {'*' * hp} | Bullets: {self.player_bullets}"

        output = [header, "=" * self.width]
        output.extend(lines)
        output.append("=" * self.width)
        output.append("Controls: WASD/Arrows = Move, SPACE = Shoot, Q = Quit")

        if self.game_over:
            output.append("")
            output.append("*** GAME OVER ***")
            output.append(f"Final Score: {self.score}")

        return '\n'.join(output)


def get_key():
    """Get a key press without blocking."""
    if select.select([sys.stdin], [], [], 0.05)[0]:
        return sys.stdin.read(1)
    return None


def main():
    """Main game loop."""
    print("ft_shmup - Space Shooter")
    print("========================")
    print()
    print("Controls:")
    print("  W/Up    - Move up")
    print("  S/Down  - Move down")
    print("  A/Left  - Move left")
    print("  D/Right - Move right")
    print("  SPACE   - Shoot")
    print("  Q       - Quit")
    print()
    print("Collect power-ups for health, speed, and extra bullets!")
    print()
    input("Press Enter to start...")

    game = Game()

    # Save terminal settings
    old_settings = termios.tcgetattr(sys.stdin)

    try:
        # Set terminal to raw mode
        tty.setcbreak(sys.stdin.fileno())

        last_update = time.time()
        shoot_cooldown = 0

        while game.running:
            # Handle input
            key = get_key()
            if key:
                if key == 'q' or key == 'Q':
                    game.running = False
                elif key == 'w' or key == 'W':
                    game.move_player(0, -1)
                elif key == 's' or key == 'S':
                    game.move_player(0, 1)
                elif key == 'a' or key == 'A':
                    game.move_player(-1, 0)
                elif key == 'd' or key == 'D':
                    game.move_player(1, 0)
                elif key == ' ':
                    if shoot_cooldown <= 0:
                        game.player_shoot()
                        shoot_cooldown = 5
                elif key == '\x1b':  # Escape sequence
                    key2 = get_key()
                    if key2 == '[':
                        key3 = get_key()
                        if key3 == 'A':  # Up
                            game.move_player(0, -1)
                        elif key3 == 'B':  # Down
                            game.move_player(0, 1)
                        elif key3 == 'C':  # Right
                            game.move_player(1, 0)
                        elif key3 == 'D':  # Left
                            game.move_player(-1, 0)

            # Update game
            current_time = time.time()
            if current_time - last_update >= 0.1:
                game.update()
                shoot_cooldown = max(0, shoot_cooldown - 1)
                last_update = current_time

                # Render
                os.system('clear' if os.name != 'nt' else 'cls')
                print(game.render())

                if game.game_over:
                    time.sleep(2)
                    game.running = False

    finally:
        # Restore terminal settings
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, old_settings)

    print("\nThanks for playing!")


if __name__ == "__main__":
    main()
