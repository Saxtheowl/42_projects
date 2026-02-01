# ft_newton - Physics Simulation Engine

Newtonian physics simulation with rigid body dynamics.

## Features

- 2D rigid body dynamics
- Circle collision detection
- Impulse-based collision resolution
- Friction and restitution
- Gravity simulation
- Multiple body interactions

## Usage

```bash
python3 ft_newton.py      # Run demo
```

## Physics Components

### Vec2
2D vector with operations:
- Addition, subtraction, scaling
- Dot product, cross product
- Normalization
- Rotation

### RigidBody
Physical object with:
- Position, velocity, acceleration
- Angular motion
- Mass and inertia
- Restitution (bounciness)
- Friction coefficient

### PhysicsWorld
Simulation container:
- Gravity
- Collision detection
- Collision resolution
- Time stepping

## API Usage

```python
from ft_newton import PhysicsWorld, RigidBody, Vec2

# Create world with gravity
world = PhysicsWorld(gravity=Vec2(0, 9.81))

# Create static ground
ground = RigidBody(
    position=Vec2(400, 500),
    radius=1000,
    is_static=True
)
world.add_body(ground)

# Create bouncing ball
ball = RigidBody(
    position=Vec2(400, 100),
    velocity=Vec2(50, 0),
    radius=20,
    mass=1.0,
    restitution=0.8
)
world.add_body(ball)

# Simulate
for _ in range(1000):
    world.step(1.0 / 60.0)
```

## Collision Resolution

Uses impulse-based resolution:
1. Detect collision overlap
2. Calculate relative velocity
3. Compute impulse magnitude
4. Apply impulse to both bodies
5. Apply positional correction
6. Apply friction

## Physics Formulas

- **Impulse**: `j = -(1 + e) * Vrel / (1/m1 + 1/m2)`
- **Projectile range**: `R = v₀² sin(2θ) / g`
- **Kinetic energy**: `KE = ½mv²`
- **Momentum**: `p = mv`

## Author

Implementation for 42 curriculum.
