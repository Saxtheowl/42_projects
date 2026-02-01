#!/usr/bin/env python3
"""
ft_newton - Physics Simulation Engine
Newtonian physics with rigid body dynamics
"""

import sys
import math
from typing import List, Tuple, Optional
from dataclasses import dataclass, field


@dataclass
class Vec2:
    """2D vector."""
    x: float = 0.0
    y: float = 0.0

    def __add__(self, other: 'Vec2') -> 'Vec2':
        return Vec2(self.x + other.x, self.y + other.y)

    def __sub__(self, other: 'Vec2') -> 'Vec2':
        return Vec2(self.x - other.x, self.y - other.y)

    def __mul__(self, scalar: float) -> 'Vec2':
        return Vec2(self.x * scalar, self.y * scalar)

    def __truediv__(self, scalar: float) -> 'Vec2':
        return Vec2(self.x / scalar, self.y / scalar)

    def __neg__(self) -> 'Vec2':
        return Vec2(-self.x, -self.y)

    def dot(self, other: 'Vec2') -> float:
        return self.x * other.x + self.y * other.y

    def cross(self, other: 'Vec2') -> float:
        return self.x * other.y - self.y * other.x

    def length(self) -> float:
        return math.sqrt(self.x**2 + self.y**2)

    def length_squared(self) -> float:
        return self.x**2 + self.y**2

    def normalize(self) -> 'Vec2':
        l = self.length()
        if l < 1e-10:
            return Vec2()
        return Vec2(self.x / l, self.y / l)

    def perpendicular(self) -> 'Vec2':
        return Vec2(-self.y, self.x)

    def rotate(self, angle: float) -> 'Vec2':
        c, s = math.cos(angle), math.sin(angle)
        return Vec2(self.x * c - self.y * s, self.x * s + self.y * c)


@dataclass
class RigidBody:
    """Rigid body with physics properties."""
    position: Vec2
    velocity: Vec2 = field(default_factory=Vec2)
    acceleration: Vec2 = field(default_factory=Vec2)
    force: Vec2 = field(default_factory=Vec2)

    angle: float = 0.0
    angular_velocity: float = 0.0
    torque: float = 0.0

    mass: float = 1.0
    inertia: float = 1.0
    restitution: float = 0.5  # Bounciness
    friction: float = 0.3

    is_static: bool = False

    # Shape (circle for simplicity)
    radius: float = 10.0

    def apply_force(self, force: Vec2, point: Optional[Vec2] = None):
        """Apply force at a point."""
        self.force = self.force + force

        if point:
            # Calculate torque
            r = point - self.position
            self.torque += r.cross(force)

    def apply_impulse(self, impulse: Vec2, point: Optional[Vec2] = None):
        """Apply impulse at a point."""
        if self.is_static:
            return

        self.velocity = self.velocity + impulse * (1.0 / self.mass)

        if point:
            r = point - self.position
            self.angular_velocity += r.cross(impulse) / self.inertia

    def integrate(self, dt: float):
        """Integrate physics state."""
        if self.is_static:
            return

        # Linear motion
        self.acceleration = self.force * (1.0 / self.mass)
        self.velocity = self.velocity + self.acceleration * dt
        self.position = self.position + self.velocity * dt

        # Angular motion
        alpha = self.torque / self.inertia
        self.angular_velocity += alpha * dt
        self.angle += self.angular_velocity * dt

        # Clear forces
        self.force = Vec2()
        self.torque = 0.0

    def inv_mass(self) -> float:
        return 0.0 if self.is_static else 1.0 / self.mass

    def inv_inertia(self) -> float:
        return 0.0 if self.is_static else 1.0 / self.inertia


@dataclass
class Collision:
    """Collision information."""
    body_a: RigidBody
    body_b: RigidBody
    normal: Vec2
    depth: float
    contact_point: Vec2


class PhysicsWorld:
    """Physics simulation world."""

    def __init__(self, gravity: Vec2 = Vec2(0, 9.81)):
        self.bodies: List[RigidBody] = []
        self.gravity = gravity
        self.iterations = 10

    def add_body(self, body: RigidBody):
        """Add a body to the world."""
        self.bodies.append(body)

    def remove_body(self, body: RigidBody):
        """Remove a body from the world."""
        self.bodies.remove(body)

    def detect_collision(self, a: RigidBody, b: RigidBody) -> Optional[Collision]:
        """Detect collision between two circles."""
        diff = b.position - a.position
        dist = diff.length()
        min_dist = a.radius + b.radius

        if dist >= min_dist:
            return None

        if dist < 1e-10:
            # Bodies at same position
            normal = Vec2(1, 0)
            depth = min_dist
        else:
            normal = diff.normalize()
            depth = min_dist - dist

        contact = a.position + normal * (a.radius - depth / 2)

        return Collision(a, b, normal, depth, contact)

    def resolve_collision(self, collision: Collision):
        """Resolve a collision."""
        a, b = collision.body_a, collision.body_b
        normal = collision.normal

        # Relative velocity
        rel_vel = b.velocity - a.velocity

        # Relative velocity along normal
        vel_along_normal = rel_vel.dot(normal)

        # Don't resolve if separating
        if vel_along_normal > 0:
            return

        # Restitution (bounciness)
        e = min(a.restitution, b.restitution)

        # Impulse scalar
        j = -(1 + e) * vel_along_normal
        j /= a.inv_mass() + b.inv_mass()

        # Apply impulse
        impulse = normal * j
        a.apply_impulse(-impulse, collision.contact_point)
        b.apply_impulse(impulse, collision.contact_point)

        # Positional correction (prevent sinking)
        percent = 0.2
        slop = 0.01
        correction = normal * (max(collision.depth - slop, 0) /
                              (a.inv_mass() + b.inv_mass()) * percent)

        if not a.is_static:
            a.position = a.position - correction * a.inv_mass()
        if not b.is_static:
            b.position = b.position + correction * b.inv_mass()

        # Friction
        tangent = rel_vel - normal * vel_along_normal
        if tangent.length_squared() > 1e-10:
            tangent = tangent.normalize()
            jt = -rel_vel.dot(tangent)
            jt /= a.inv_mass() + b.inv_mass()

            mu = (a.friction + b.friction) / 2

            if abs(jt) < j * mu:
                friction_impulse = tangent * jt
            else:
                friction_impulse = tangent * (-j * mu)

            a.apply_impulse(-friction_impulse, collision.contact_point)
            b.apply_impulse(friction_impulse, collision.contact_point)

    def step(self, dt: float):
        """Step the simulation."""
        # Apply gravity
        for body in self.bodies:
            if not body.is_static:
                body.apply_force(self.gravity * body.mass)

        # Integrate forces
        for body in self.bodies:
            body.integrate(dt)

        # Detect and resolve collisions
        for _ in range(self.iterations):
            for i, a in enumerate(self.bodies):
                for b in self.bodies[i + 1:]:
                    collision = self.detect_collision(a, b)
                    if collision:
                        self.resolve_collision(collision)


def run_demo():
    """Run physics demo."""
    print("ft_newton - Physics Simulation Demo")
    print("=" * 50)

    world = PhysicsWorld(gravity=Vec2(0, 100))

    # Create ground
    ground = RigidBody(
        position=Vec2(400, 580),
        radius=1000,
        is_static=True
    )
    world.add_body(ground)

    # Create balls
    balls = []
    for i in range(5):
        ball = RigidBody(
            position=Vec2(200 + i * 80, 100 + i * 20),
            velocity=Vec2(50 - i * 20, 0),
            radius=20,
            mass=1.0,
            restitution=0.7
        )
        world.add_body(ball)
        balls.append(ball)

    # Simulate
    dt = 1.0 / 60.0
    print(f"\nSimulating {len(balls)} balls with gravity...")

    for step in range(300):
        world.step(dt)

        if step % 60 == 0:
            print(f"\nTime: {step * dt:.2f}s")
            for i, ball in enumerate(balls):
                print(f"  Ball {i}: pos=({ball.position.x:.1f}, {ball.position.y:.1f}), "
                      f"vel=({ball.velocity.x:.1f}, {ball.velocity.y:.1f})")

    print("\n" + "=" * 50)

    # Demo 2: Newton's Cradle
    print("\nNewton's Cradle Demo")
    print("-" * 40)

    world2 = PhysicsWorld(gravity=Vec2(0, 0))

    # Cradle balls in a row
    cradle = []
    for i in range(5):
        ball = RigidBody(
            position=Vec2(300 + i * 42, 300),
            radius=20,
            mass=1.0,
            restitution=1.0,  # Perfect elastic
            friction=0.0
        )
        world2.add_body(ball)
        cradle.append(ball)

    # Give first ball velocity
    cradle[0].velocity = Vec2(100, 0)

    print("Initial: First ball moving right")
    print(f"  Ball 0 velocity: {cradle[0].velocity.x:.1f}")

    for step in range(100):
        world2.step(dt)

    print("\nAfter collision:")
    for i, ball in enumerate(cradle):
        if abs(ball.velocity.x) > 0.1:
            print(f"  Ball {i} velocity: {ball.velocity.x:.1f}")

    print("\n(Last ball should be moving, demonstrating momentum transfer)")

    # Demo 3: Projectile Motion
    print("\n" + "=" * 50)
    print("\nProjectile Motion Demo")
    print("-" * 40)

    world3 = PhysicsWorld(gravity=Vec2(0, 9.81))

    projectile = RigidBody(
        position=Vec2(0, 0),
        velocity=Vec2(50, -30),  # 45-degree launch
        radius=5,
        mass=1.0
    )
    world3.add_body(projectile)

    print(f"Launch velocity: ({projectile.velocity.x:.1f}, {projectile.velocity.y:.1f})")

    max_height = 0
    range_x = 0

    for step in range(200):
        world3.step(dt)
        max_height = max(max_height, -projectile.position.y)

        if projectile.position.y > 0:
            range_x = projectile.position.x
            break

    print(f"Max height: {max_height:.1f}")
    print(f"Range: {range_x:.1f}")

    # Theoretical values
    v0 = math.sqrt(50**2 + 30**2)
    angle = math.atan2(30, 50)
    g = 9.81
    theoretical_height = (v0 * math.sin(angle))**2 / (2 * g)
    theoretical_range = (v0**2 * math.sin(2 * angle)) / g

    print(f"\nTheoretical:")
    print(f"  Max height: {theoretical_height:.1f}")
    print(f"  Range: {theoretical_range:.1f}")


def main():
    """Main entry point."""
    if len(sys.argv) > 1 and sys.argv[1] == '--help':
        print("ft_newton - Physics Simulation Engine")
        print()
        print("Usage:")
        print("  python ft_newton.py       - Run demo")
        print()
        print("Features:")
        print("  - Rigid body dynamics")
        print("  - Circle collision detection")
        print("  - Impulse-based resolution")
        print("  - Friction and restitution")
        print("  - Gravity")
        return

    run_demo()


if __name__ == "__main__":
    main()
