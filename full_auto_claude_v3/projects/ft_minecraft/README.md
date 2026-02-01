# ft_minecraft - Voxel Engine

Simple Minecraft-like voxel world engine.

## Features

- Chunk-based world (16x256x16)
- Procedural terrain generation
- Tree placement
- Block manipulation (break/place)
- Player movement
- Ray casting for targeting
- ASCII rendering

## Usage

```bash
python3 ft_minecraft.py
```

## Block Types

| Block | Symbol | Description |
|-------|--------|-------------|
| GRASS | # | Top layer |
| DIRT | . | Under grass |
| STONE | % | Deep layer |
| SAND | : | Beach/desert |
| WATER | ~ | Lakes/ocean |
| WOOD | \| | Tree trunk |
| LEAVES | * | Tree leaves |
| COBBLESTONE | @ | Crafted |
| BEDROCK | = | Indestructible |

## World Structure

- World divided into chunks
- Each chunk: 16x256x16 blocks
- Chunks generated on demand
- Seeded random for consistency

## Player Actions

- Move forward/backward
- Strafe left/right
- Look (yaw/pitch)
- Break block (ray cast)
- Place block (adjacent)

## API Usage

```python
from ft_minecraft import World, Player, BlockType

# Create world
world = World(seed=42)

# Create player
player = Player(world)

# Move and look
player.move(5, 0)
player.look(90, 0)

# Block operations
world.set_block(0, 64, 0, BlockType.STONE)
block = world.get_block(0, 64, 0)

# Ray casting
target = player.get_target_block()
player.break_block()
player.place_block(BlockType.COBBLESTONE)
```

## Terrain Generation

1. Height map from sine waves
2. Bedrock at y=0
3. Stone from y=1 to height-4
4. Dirt from height-4 to height
5. Grass at height
6. Random trees

## Author

Implementation for 42 curriculum.
