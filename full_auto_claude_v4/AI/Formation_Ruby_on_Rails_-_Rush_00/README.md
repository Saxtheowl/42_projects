# MovieMon - Formation Ruby on Rails Rush 00

A Pokemon-inspired web game built with Ruby on Rails where you capture "MovieMons" (monster movies) instead of Pokemon.

## Overview

MovieMon is a stateless Rails application that features:
- A Game Boy-style interface with green screen aesthetic
- Grid-based exploration (10x10 map)
- Turn-based combat system based on movie ratings
- Collection system (Moviedex) to view captured MovieMons
- Save/Load functionality with 3 save slots (JSON format)

## Requirements

- Ruby >= 2.3.0
- Rails ~> 5.2.0 (or 4.2.7 as per subject)
- No database required (stateless application)
- No JavaScript (pure HTML/CSS)

## Installation

```bash
cd moviemon
bundle install
```

## Running the Application

```bash
rails server
```

Then open your browser to `http://localhost:3000`

## Game Controls

The interface mimics a Game Boy with these controls:

| Button | Function |
|--------|----------|
| D-Pad (Up/Down/Left/Right) | Navigation / Movement |
| Start | New Game (title) / Moviedex (worldmap) |
| Select | Load Game (title) / Save Game (worldmap) |
| A | Confirm / Fight |
| B | Cancel / Flee |
| Power (LED) | Reset game |

## Screens

### Title Screen
- **Start**: Begin a new game
- **Select**: Access save slots to load a game

### Worldmap
- Move with D-Pad arrows
- Random encounters when moving
- **Start**: Open Moviedex
- **Select**: Save game

### Battle
- Shows MovieMon poster, name, director, energy
- **A**: Attack (both exchange hits based on their hit points)
- **B**: Flee (restore energy, MovieMon stays available)

### Moviedex
- Browse captured MovieMons
- **Left/Right**: Navigate between captures
- **Start**: Return to worldmap

### Save Slots
- 3 save slots (A, B, C)
- **Up/Down**: Select slot
- **A**: Save/Load depending on context
- **Select**: Return to previous screen

## Game Mechanics

### Combat System
- Player starts with 100 energy and 10 hit points
- MovieMon energy = rating * 10
- MovieMon hit points = rating value
- Each fight: both sides deal damage simultaneously
- Capture success: MovieMon energy reaches 0 first
- Capture failure: Player energy reaches 0 first (MovieMon escapes permanently)
- Fleeing: Restores player energy, MovieMon stays in the wild

### Progression
- Capturing a MovieMon increases player hit points by 2
- Goal: Capture all 10 MovieMons!

## Technical Details

### No Database
This is a stateless application that uses:
- Global variables: `$view`, `$selected`, `$game`, `$player`
- JSON file for save data (`saves/save.json`)

### No ActiveRecord
Models do not inherit from ActiveRecord::Base. The `Game` model is a plain Ruby class.

### No Forbidden Ruby Keywords
The code avoids: `while`, `for`, `redo`, `break`, `retry`, `loop`, `until`

### File Structure

```
moviemon/
├── app/
│   ├── controllers/
│   │   └── game_controller.rb
│   ├── models/
│   │   └── game.rb
│   └── views/
│       ├── layouts/
│       │   └── application.html.erb
│       └── game/
│           ├── title.html.erb
│           ├── worldmap.html.erb
│           ├── battle.html.erb
│           ├── battle_result.html.erb
│           ├── moviedex.html.erb
│           └── save_slots.html.erb
├── config/
│   └── routes.rb
├── saves/
│   └── save.json (created on first save)
├── test/
│   └── test_game.rb
└── requirement.txt
```

## Testing

```bash
ruby test/test_game.rb
```

Tests cover:
- Game initialization
- Movement mechanics
- Combat system
- Save/Load functionality
- No forbidden Ruby keywords

## MovieMons Available

1. **Godzilla** (2014) - Rating: 6.4
2. **Kong: Skull Island** (2017) - Rating: 6.7
3. **Alien** (1979) - Rating: 8.5
4. **Jaws** (1975) - Rating: 8.1
5. **Predator** (1987) - Rating: 7.8
6. **The Thing** (1982) - Rating: 8.2
7. **Cloverfield** (2008) - Rating: 7.0
8. **Pacific Rim** (2013) - Rating: 6.9
9. **Jurassic Park** (1993) - Rating: 8.2
10. **Tremors** (1990) - Rating: 7.1

## Verification

To verify no ActiveRecord subclasses exist:
```ruby
# In Rails console
ActiveRecord::Base.subclasses.map { |forbid| forbid.name }
# Should return empty array []
```

## Author

42 Formation Ruby on Rails - Rush 00
