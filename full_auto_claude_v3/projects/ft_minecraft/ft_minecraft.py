#!/usr/bin/env python3
"""
ft_minecraft - Voxel Engine
Simple voxel world with block manipulation
"""

import sys
import math
from typing import Dict, Tuple, List, Optional
from dataclasses import dataclass
from enum import Enum


class BlockType(Enum):
    AIR = 0
    GRASS = 1
    DIRT = 2
    STONE = 3
    SAND = 4
    WATER = 5
    WOOD = 6
    LEAVES = 7
    COBBLESTONE = 8
    BEDROCK = 9


@dataclass
class Vec3:
    """3D vector/position."""
    x: float
    y: float
    z: float

    def __add__(self, other: 'Vec3') -> 'Vec3':
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other: 'Vec3') -> 'Vec3':
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)

    def __mul__(self, scalar: float) -> 'Vec3':
        return Vec3(self.x * scalar, self.y * scalar, self.z * scalar)

    def to_block(self) -> Tuple[int, int, int]:
        return (int(self.x), int(self.y), int(self.z))


class Chunk:
    """A 16x16x256 chunk of blocks."""
    SIZE_X = 16
    SIZE_Y = 256
    SIZE_Z = 16

    def __init__(self, cx: int, cz: int):
        self.cx = cx
        self.cz = cz
        self.blocks = {}  # (x, y, z) -> BlockType
        self.modified = False

    def get_block(self, x: int, y: int, z: int) -> BlockType:
        """Get block at local position."""
        if y < 0 or y >= self.SIZE_Y:
            return BlockType.AIR
        return self.blocks.get((x, y, z), BlockType.AIR)

    def set_block(self, x: int, y: int, z: int, block_type: BlockType):
        """Set block at local position."""
        if 0 <= y < self.SIZE_Y:
            if block_type == BlockType.AIR:
                self.blocks.pop((x, y, z), None)
            else:
                self.blocks[(x, y, z)] = block_type
            self.modified = True

    def generate(self, seed: int = 42):
        """Generate terrain for this chunk."""
        import random
        random.seed(seed + self.cx * 1000 + self.cz)

        for x in range(self.SIZE_X):
            for z in range(self.SIZE_Z):
                # Simple height map using sine waves
                world_x = self.cx * self.SIZE_X + x
                world_z = self.cz * self.SIZE_Z + z

                height = 64  # Base height
                height += int(8 * math.sin(world_x / 20.0))
                height += int(4 * math.sin(world_z / 15.0))
                height += int(2 * math.sin((world_x + world_z) / 10.0))
                height = max(1, min(128, height))

                # Bedrock layer
                self.set_block(x, 0, z, BlockType.BEDROCK)

                # Stone layers
                for y in range(1, height - 4):
                    self.set_block(x, y, z, BlockType.STONE)

                # Dirt layers
                for y in range(height - 4, height):
                    self.set_block(x, y, z, BlockType.DIRT)

                # Grass top
                self.set_block(x, height, z, BlockType.GRASS)

                # Trees (random)
                if random.random() < 0.02 and height > 64:
                    self._place_tree(x, height + 1, z)

    def _place_tree(self, x: int, y: int, z: int):
        """Place a tree at position."""
        # Trunk
        for dy in range(5):
            if 0 <= x < self.SIZE_X and 0 <= z < self.SIZE_Z:
                self.set_block(x, y + dy, z, BlockType.WOOD)

        # Leaves
        for dx in range(-2, 3):
            for dy in range(3, 6):
                for dz in range(-2, 3):
                    lx, ly, lz = x + dx, y + dy, z + dz
                    if 0 <= lx < self.SIZE_X and 0 <= lz < self.SIZE_Z:
                        if abs(dx) + abs(dz) < 4 - (dy - 3):
                            if self.get_block(lx, ly, lz) == BlockType.AIR:
                                self.set_block(lx, ly, lz, BlockType.LEAVES)


class World:
    """Voxel world made of chunks."""

    def __init__(self, seed: int = 42):
        self.seed = seed
        self.chunks: Dict[Tuple[int, int], Chunk] = {}

    def get_chunk(self, cx: int, cz: int) -> Chunk:
        """Get or generate chunk."""
        key = (cx, cz)
        if key not in self.chunks:
            chunk = Chunk(cx, cz)
            chunk.generate(self.seed)
            self.chunks[key] = chunk
        return self.chunks[key]

    def get_block(self, x: int, y: int, z: int) -> BlockType:
        """Get block at world position."""
        cx = x // Chunk.SIZE_X
        cz = z // Chunk.SIZE_Z
        lx = x % Chunk.SIZE_X
        lz = z % Chunk.SIZE_Z
        return self.get_chunk(cx, cz).get_block(lx, y, lz)

    def set_block(self, x: int, y: int, z: int, block_type: BlockType):
        """Set block at world position."""
        cx = x // Chunk.SIZE_X
        cz = z // Chunk.SIZE_Z
        lx = x % Chunk.SIZE_X
        lz = z % Chunk.SIZE_Z
        self.get_chunk(cx, cz).set_block(lx, y, lz, block_type)

    def get_height(self, x: int, z: int) -> int:
        """Get highest non-air block at x, z."""
        for y in range(255, -1, -1):
            if self.get_block(x, y, z) != BlockType.AIR:
                return y
        return 0


class Player:
    """Player in the world."""

    def __init__(self, world: World):
        self.world = world
        # Spawn at center
        spawn_y = world.get_height(0, 0) + 2
        self.position = Vec3(0.5, spawn_y, 0.5)
        self.velocity = Vec3(0, 0, 0)
        self.yaw = 0.0   # Horizontal rotation
        self.pitch = 0.0  # Vertical rotation

    def move(self, forward: float, strafe: float):
        """Move player."""
        dx = forward * math.sin(math.radians(self.yaw))
        dz = forward * math.cos(math.radians(self.yaw))
        dx += strafe * math.sin(math.radians(self.yaw + 90))
        dz += strafe * math.cos(math.radians(self.yaw + 90))

        new_pos = self.position + Vec3(dx, 0, dz)

        # Simple collision
        block = self.world.get_block(*new_pos.to_block())
        if block == BlockType.AIR:
            self.position = new_pos

    def look(self, dyaw: float, dpitch: float):
        """Rotate camera."""
        self.yaw = (self.yaw + dyaw) % 360
        self.pitch = max(-90, min(90, self.pitch + dpitch))

    def get_target_block(self, max_dist: float = 5.0) -> Optional[Tuple[int, int, int]]:
        """Ray cast to find targeted block."""
        dx = math.sin(math.radians(self.yaw)) * math.cos(math.radians(self.pitch))
        dy = -math.sin(math.radians(self.pitch))
        dz = math.cos(math.radians(self.yaw)) * math.cos(math.radians(self.pitch))

        ray = Vec3(dx, dy, dz)
        pos = self.position

        for _ in range(int(max_dist * 10)):
            pos = pos + ray * 0.1
            block_pos = pos.to_block()
            block = self.world.get_block(*block_pos)
            if block != BlockType.AIR:
                return block_pos

        return None

    def break_block(self):
        """Break targeted block."""
        target = self.get_target_block()
        if target:
            x, y, z = target
            block = self.world.get_block(x, y, z)
            if block != BlockType.BEDROCK:
                self.world.set_block(x, y, z, BlockType.AIR)
                return True
        return False

    def place_block(self, block_type: BlockType):
        """Place block adjacent to target."""
        target = self.get_target_block()
        if target:
            # Find adjacent air block
            x, y, z = target
            for dx, dy, dz in [(1,0,0), (-1,0,0), (0,1,0), (0,-1,0), (0,0,1), (0,0,-1)]:
                nx, ny, nz = x + dx, y + dy, z + dz
                if self.world.get_block(nx, ny, nz) == BlockType.AIR:
                    self.world.set_block(nx, ny, nz, block_type)
                    return True
        return False


def render_ascii(world: World, player: Player, width: int = 40, height: int = 20):
    """Render a top-down ASCII view."""
    px, py, pz = int(player.position.x), int(player.position.y), int(player.position.z)

    block_chars = {
        BlockType.AIR: ' ',
        BlockType.GRASS: '#',
        BlockType.DIRT: '.',
        BlockType.STONE: '%',
        BlockType.SAND: ':',
        BlockType.WATER: '~',
        BlockType.WOOD: '|',
        BlockType.LEAVES: '*',
        BlockType.COBBLESTONE: '@',
        BlockType.BEDROCK: '=',
    }

    print(f"Position: ({px}, {py}, {pz}) Yaw: {player.yaw:.0f}")
    print("+" + "-" * width + "+")

    for dz in range(-height // 2, height // 2):
        row = "|"
        for dx in range(-width // 2, width // 2):
            x, z = px + dx, pz + dz
            if dx == 0 and dz == 0:
                row += '@'  # Player
            else:
                # Find highest block
                y = world.get_height(x, z)
                block = world.get_block(x, y, z)
                row += block_chars.get(block, '?')
        row += "|"
        print(row)

    print("+" + "-" * width + "+")


def run_demo():
    """Run demo."""
    print("ft_minecraft - Voxel Engine Demo")
    print("=" * 50)

    world = World(seed=12345)
    player = Player(world)

    print("\nGenerating world...")
    # Pre-generate some chunks
    for cx in range(-1, 2):
        for cz in range(-1, 2):
            world.get_chunk(cx, cz)

    print(f"Generated {len(world.chunks)} chunks")
    print(f"Player at: ({player.position.x:.1f}, {player.position.y:.1f}, {player.position.z:.1f})")

    print("\n[Top-down view]")
    render_ascii(world, player)

    # Demo actions
    print("\nDemo actions:")

    print("  Moving forward...")
    player.move(5, 0)
    print(f"  New position: ({player.position.x:.1f}, {player.position.y:.1f}, {player.position.z:.1f})")

    print("  Turning right...")
    player.look(90, 0)
    print(f"  New yaw: {player.yaw}")

    print("  Looking at block...")
    target = player.get_target_block()
    if target:
        block = world.get_block(*target)
        print(f"  Target: {target} = {block.name}")

    print("\n[Updated view]")
    render_ascii(world, player)

    print("\n" + "=" * 50)
    print("Demo complete!")


def main():
    """Main entry point."""
    if len(sys.argv) > 1 and sys.argv[1] == '--help':
        print("ft_minecraft - Voxel Engine")
        print()
        print("Usage: python ft_minecraft.py")
        print()
        print("Features:")
        print("  - Chunk-based world")
        print("  - Terrain generation")
        print("  - Tree placement")
        print("  - Block breaking/placing")
        print("  - Player movement")
        print("  - Ray casting")
        return

    run_demo()


if __name__ == "__main__":
    main()
