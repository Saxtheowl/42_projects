#!/usr/bin/env python3
"""
particle_system - Particle Effects Engine
GPU-style particle simulation with PPM output
"""

import sys
import math
import random
from typing import List, Tuple, Optional
from dataclasses import dataclass, field


@dataclass
class Vec3:
    """3D vector."""
    x: float = 0.0
    y: float = 0.0
    z: float = 0.0

    def __add__(self, other: 'Vec3') -> 'Vec3':
        return Vec3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __sub__(self, other: 'Vec3') -> 'Vec3':
        return Vec3(self.x - other.x, self.y - other.y, self.z - other.z)

    def __mul__(self, scalar: float) -> 'Vec3':
        return Vec3(self.x * scalar, self.y * scalar, self.z * scalar)

    def length(self) -> float:
        return math.sqrt(self.x**2 + self.y**2 + self.z**2)

    def normalize(self) -> 'Vec3':
        l = self.length()
        if l < 0.0001:
            return Vec3()
        return Vec3(self.x/l, self.y/l, self.z/l)


@dataclass
class Color:
    """RGBA color."""
    r: float = 1.0
    g: float = 1.0
    b: float = 1.0
    a: float = 1.0

    def blend(self, other: 'Color', t: float) -> 'Color':
        return Color(
            self.r + (other.r - self.r) * t,
            self.g + (other.g - self.g) * t,
            self.b + (other.b - self.b) * t,
            self.a + (other.a - self.a) * t
        )

    def to_rgb(self) -> Tuple[int, int, int]:
        return (
            int(max(0, min(255, self.r * 255))),
            int(max(0, min(255, self.g * 255))),
            int(max(0, min(255, self.b * 255)))
        )


@dataclass
class Particle:
    """A single particle."""
    position: Vec3
    velocity: Vec3
    acceleration: Vec3 = field(default_factory=Vec3)
    color: Color = field(default_factory=Color)
    size: float = 1.0
    life: float = 1.0
    max_life: float = 1.0
    active: bool = True

    def update(self, dt: float):
        """Update particle state."""
        if not self.active:
            return

        # Update physics
        self.velocity = self.velocity + self.acceleration * dt
        self.position = self.position + self.velocity * dt

        # Decay life
        self.life -= dt
        if self.life <= 0:
            self.active = False

    def get_life_ratio(self) -> float:
        """Get life as 0-1 ratio."""
        return max(0, self.life / self.max_life) if self.max_life > 0 else 0


class Emitter:
    """Particle emitter."""

    def __init__(self, position: Vec3, rate: float = 100):
        self.position = position
        self.rate = rate  # Particles per second
        self.particles: List[Particle] = []
        self.time_accumulator = 0.0

        # Emission parameters
        self.velocity_min = Vec3(-1, -1, 0)
        self.velocity_max = Vec3(1, 1, 0)
        self.life_min = 1.0
        self.life_max = 3.0
        self.size_min = 1.0
        self.size_max = 5.0
        self.color_start = Color(1, 1, 0, 1)  # Yellow
        self.color_end = Color(1, 0, 0, 0)    # Red, transparent
        self.gravity = Vec3(0, 9.8, 0)        # Gravity
        self.spread = 30.0                     # Cone angle

    def emit_particle(self) -> Particle:
        """Emit a new particle."""
        # Random velocity in cone
        angle = random.uniform(0, 2 * math.pi)
        spread_rad = math.radians(self.spread)
        spread_factor = random.uniform(0, math.tan(spread_rad))

        vx = math.cos(angle) * spread_factor
        vy = -1  # Upward
        vz = math.sin(angle) * spread_factor

        speed = random.uniform(50, 100)
        velocity = Vec3(vx, vy, vz).normalize() * speed

        # Random life
        life = random.uniform(self.life_min, self.life_max)

        # Random size
        size = random.uniform(self.size_min, self.size_max)

        return Particle(
            position=Vec3(self.position.x, self.position.y, self.position.z),
            velocity=velocity,
            acceleration=self.gravity,
            color=Color(self.color_start.r, self.color_start.g,
                       self.color_start.b, self.color_start.a),
            size=size,
            life=life,
            max_life=life
        )

    def update(self, dt: float):
        """Update emitter and particles."""
        # Emit new particles
        self.time_accumulator += dt
        particles_to_emit = int(self.time_accumulator * self.rate)
        self.time_accumulator -= particles_to_emit / self.rate

        for _ in range(particles_to_emit):
            self.particles.append(self.emit_particle())

        # Update existing particles
        for p in self.particles:
            p.update(dt)

            # Update color based on life
            t = 1 - p.get_life_ratio()
            p.color = self.color_start.blend(self.color_end, t)

            # Fade size
            p.size = p.size * (0.5 + 0.5 * p.get_life_ratio())

        # Remove dead particles
        self.particles = [p for p in self.particles if p.active]


class ParticleSystem:
    """Complete particle system."""

    def __init__(self, width: int = 800, height: int = 600):
        self.width = width
        self.height = height
        self.emitters: List[Emitter] = []
        self.buffer = [[(0, 0, 0) for _ in range(width)] for _ in range(height)]

    def add_emitter(self, emitter: Emitter):
        """Add an emitter."""
        self.emitters.append(emitter)

    def update(self, dt: float):
        """Update all emitters."""
        for emitter in self.emitters:
            emitter.update(dt)

    def clear(self):
        """Clear render buffer."""
        self.buffer = [[(0, 0, 0) for _ in range(self.width)]
                       for _ in range(self.height)]

    def render(self):
        """Render particles to buffer."""
        self.clear()

        for emitter in self.emitters:
            for particle in emitter.particles:
                self.render_particle(particle)

    def render_particle(self, p: Particle):
        """Render a single particle."""
        x = int(p.position.x)
        y = int(p.position.y)
        size = int(p.size)

        color = p.color.to_rgb()
        alpha = p.color.a * p.get_life_ratio()

        # Draw circular particle
        for dy in range(-size, size + 1):
            for dx in range(-size, size + 1):
                if dx*dx + dy*dy <= size*size:
                    px = x + dx
                    py = y + dy
                    if 0 <= px < self.width and 0 <= py < self.height:
                        # Blend with existing color
                        old = self.buffer[py][px]
                        new = (
                            int(old[0] * (1 - alpha) + color[0] * alpha),
                            int(old[1] * (1 - alpha) + color[1] * alpha),
                            int(old[2] * (1 - alpha) + color[2] * alpha)
                        )
                        self.buffer[py][px] = new

    def save_ppm(self, filename: str):
        """Save buffer as PPM."""
        with open(filename, 'w') as f:
            f.write("P3\n")
            f.write(f"{self.width} {self.height}\n")
            f.write("255\n")

            for row in self.buffer:
                for r, g, b in row:
                    f.write(f"{r} {g} {b}\n")

        print(f"Saved: {filename}")

    def get_particle_count(self) -> int:
        """Get total particle count."""
        return sum(len(e.particles) for e in self.emitters)


def create_fire_emitter(x: float, y: float) -> Emitter:
    """Create a fire effect emitter."""
    emitter = Emitter(Vec3(x, y, 0), rate=200)
    emitter.color_start = Color(1, 0.8, 0, 1)  # Orange
    emitter.color_end = Color(0.5, 0, 0, 0)    # Dark red
    emitter.life_min = 0.5
    emitter.life_max = 1.5
    emitter.size_min = 2
    emitter.size_max = 8
    emitter.gravity = Vec3(0, -50, 0)  # Upward
    emitter.spread = 20
    return emitter


def create_explosion_emitter(x: float, y: float) -> Emitter:
    """Create an explosion effect emitter."""
    emitter = Emitter(Vec3(x, y, 0), rate=500)
    emitter.color_start = Color(1, 1, 0.5, 1)  # Bright yellow
    emitter.color_end = Color(1, 0.3, 0, 0)    # Orange-red
    emitter.life_min = 0.3
    emitter.life_max = 1.0
    emitter.size_min = 3
    emitter.size_max = 10
    emitter.gravity = Vec3(0, 20, 0)  # Slight downward
    emitter.spread = 180  # All directions
    return emitter


def create_fountain_emitter(x: float, y: float) -> Emitter:
    """Create a fountain effect emitter."""
    emitter = Emitter(Vec3(x, y, 0), rate=150)
    emitter.color_start = Color(0.3, 0.5, 1, 1)  # Blue
    emitter.color_end = Color(0.1, 0.3, 0.8, 0)  # Darker blue
    emitter.life_min = 1.0
    emitter.life_max = 2.5
    emitter.size_min = 2
    emitter.size_max = 5
    emitter.gravity = Vec3(0, 100, 0)  # Gravity
    emitter.spread = 15
    return emitter


def create_snow_emitter(width: int) -> Emitter:
    """Create a snow effect emitter."""
    emitter = Emitter(Vec3(width / 2, 0, 0), rate=50)
    emitter.color_start = Color(1, 1, 1, 1)  # White
    emitter.color_end = Color(0.8, 0.8, 1, 0.5)  # Light blue
    emitter.life_min = 3.0
    emitter.life_max = 6.0
    emitter.size_min = 1
    emitter.size_max = 3
    emitter.gravity = Vec3(0, 30, 0)  # Slow fall
    emitter.spread = 90  # Wide spread

    # Override position to span width
    original_emit = emitter.emit_particle

    def emit_snow():
        p = original_emit()
        p.position.x = random.uniform(0, width)
        p.velocity.x = random.uniform(-10, 10)  # Drift
        return p

    emitter.emit_particle = emit_snow
    return emitter


def run_demo():
    """Run particle system demo."""
    print("Particle System Demo")
    print("=" * 50)

    system = ParticleSystem(800, 600)

    # Add various emitters
    print("Creating emitters...")

    # Fire at bottom center
    fire = create_fire_emitter(400, 550)
    system.add_emitter(fire)

    # Fountain at left
    fountain = create_fountain_emitter(150, 500)
    system.add_emitter(fountain)

    # Simulate and render frames
    dt = 0.016  # ~60 FPS
    total_time = 3.0  # 3 seconds

    print(f"Simulating {total_time}s at {1/dt:.0f} FPS...")

    frames = int(total_time / dt)
    for frame in range(frames):
        system.update(dt)

        # Save keyframes
        if frame % 30 == 0:
            system.render()
            filename = f"particles_{frame:04d}.ppm"
            system.save_ppm(filename)
            print(f"  Frame {frame}: {system.get_particle_count()} particles")

    # Final frame
    system.render()
    system.save_ppm("particles_final.ppm")

    print(f"\nFinal particle count: {system.get_particle_count()}")
    print("Demo complete!")


def main():
    """Main entry point."""
    if len(sys.argv) > 1:
        if sys.argv[1] == '--help':
            print("particle_system - Particle Effects Engine")
            print()
            print("Usage:")
            print("  python particle_system.py          - Run demo")
            print("  python particle_system.py --help   - Show help")
            print()
            print("Effects available:")
            print("  - Fire (upward flames)")
            print("  - Explosion (radial burst)")
            print("  - Fountain (water jet)")
            print("  - Snow (falling particles)")
            return

    run_demo()


if __name__ == "__main__":
    main()
