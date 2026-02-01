# Swingy - Java RPG Game

Text-based RPG game with GUI option in Java.

## Note

This project requires Java and optionally Swing for GUI.

## Features

- Hero creation
- Map exploration
- Combat system
- Leveling
- Artifacts
- Save/Load

## Usage

```bash
# Console mode
java -jar swingy.jar console

# GUI mode
java -jar swingy.jar gui
```

## Hero Types

| Class | HP | Attack | Defense |
|-------|----|----|---------|
| Warrior | 100 | 15 | 10 |
| Mage | 60 | 25 | 5 |
| Rogue | 80 | 20 | 7 |

## Artifacts

| Slot | Effect |
|------|--------|
| Weapon | +Attack |
| Armor | +Defense |
| Helm | +HP |

## Leveling Formula

```
Level = floor((level - 1) * 1000 + (level - 1)^2 * 450)
```

| Level | XP Required |
|-------|-------------|
| 1 | 0 |
| 2 | 1000 |
| 3 | 2900 |
| 4 | 5800 |
| 5 | 9700 |

## Map Generation

- Size = (level - 1) * 5 + 10 - (level % 2)
- Hero starts at center
- Villains placed randomly
- Villain level = max(1, hero_level + [-2, 2])

## Combat

1. Player can Fight or Run
2. Running: 50% success
3. Fighting: Compare stats
4. Winner gets XP

## Game Loop

1. Display map
2. Player moves (N/S/E/W)
3. If enemy: Fight or Run
4. If edge: Win
5. Repeat

## Data Validation

- Hero name: required
- Attack/Defense: positive
- Level: >= 1
- Coordinates: within map

## Save System

Heroes saved to database:
- Name
- Class
- Level
- Experience
- Artifacts

## MVC Pattern

- Model: Hero, Villain, Map
- View: Console or GUI
- Controller: Game logic

## Author

Implementation guide for 42 curriculum.
