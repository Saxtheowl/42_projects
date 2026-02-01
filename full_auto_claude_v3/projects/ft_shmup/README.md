# ft_shmup - Shoot 'em Up Game

Space shooter arcade game with enemies, bullets, and power-ups.

## Features

- Player ship with movement and shooting
- Multiple enemy types (basic, medium, heavy)
- Enemy bullets and collision detection
- Power-up system (health, speed, extra bullets)
- Progressive difficulty with levels
- Score tracking

## Usage

```bash
python3 ft_shmup.py
```

## Controls

| Key | Action |
|-----|--------|
| W / Up Arrow | Move up |
| S / Down Arrow | Move down |
| A / Left Arrow | Move left |
| D / Right Arrow | Move right |
| SPACE | Shoot |
| Q | Quit |

## Power-ups

| Symbol | Effect |
|--------|--------|
| [+] | Restore health |
| [*] | Extra bullet |
| [>] | Speed boost |

## Enemy Types

- **Basic** `<-->`: 1 HP, fast
- **Medium** `<##>`: 2 HP, moderate speed
- **Heavy** `|####|`: 3 HP, slow

## Scoring

- Basic enemy: 100 points
- Medium enemy: 100 points
- Heavy enemy: 100 points
- Power-up: 50 points
- Level up every 1000 points

## Author

Implementation for 42 curriculum.
