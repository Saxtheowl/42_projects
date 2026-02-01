# particle_system - Particle Effects Engine

GPU-style particle simulation with PPM output.

## Features

- Physics-based particles
- Multiple emitter types
- Color interpolation over lifetime
- Alpha blending
- Particle aging and death
- PPM frame output

## Usage

```bash
python3 particle_system.py      # Run demo
```

## Effect Types

| Effect | Description |
|--------|-------------|
| Fire | Upward flames with orange-red gradient |
| Explosion | Radial burst with bright flash |
| Fountain | Water jet with gravity |
| Snow | Falling particles with drift |

## Particle Properties

- Position (x, y, z)
- Velocity (x, y, z)
- Acceleration (gravity, wind)
- Color (RGBA with interpolation)
- Size (with scaling over time)
- Lifetime (fade out)

## Emitter Configuration

```python
from particle_system import Emitter, Vec3, Color

emitter = Emitter(Vec3(400, 300, 0), rate=100)
emitter.color_start = Color(1, 1, 0, 1)  # Yellow
emitter.color_end = Color(1, 0, 0, 0)    # Red
emitter.life_min = 0.5
emitter.life_max = 2.0
emitter.size_min = 2
emitter.size_max = 8
emitter.gravity = Vec3(0, 50, 0)
emitter.spread = 30  # Degrees
```

## System Usage

```python
from particle_system import ParticleSystem

system = ParticleSystem(800, 600)
system.add_emitter(create_fire_emitter(400, 500))

# Simulate
for _ in range(100):
    system.update(0.016)  # 60 FPS

# Render
system.render()
system.save_ppm("output.ppm")
```

## Output

Generates PPM image files that can be:
- Viewed with image viewers
- Converted to GIF/video with ffmpeg
- Used for testing/visualization

## Author

Implementation for 42 curriculum.
