# So_Long

A 42 school project - A simple 2D game where a character collects items and escapes.

## Description

So_Long is a small 2D game created using the MiniLibX graphics library. The player must collect all collectibles on the map and then reach the exit, taking the shortest possible route. The game helps develop skills in window management, event handling, textures, and basic game mechanics.

## Game Mechanics

- **Objective**: Collect all collectibles (C) and reach the exit (E)
- **Controls**: W/A/S/D or Arrow keys to move
- **Rules**:
  - Cannot move through walls (1)
  - Must collect all items before the exit opens
  - Movement count is displayed in the terminal
  - ESC or window close button to quit

## Map Format

Maps are stored in `.ber` files with the following characters:

- `0` - Empty space
- `1` - Wall
- `C` - Collectible
- `E` - Exit
- `P` - Player starting position

### Map Requirements

- Must be rectangular
- Must be surrounded by walls
- Must contain exactly 1 player (P)
- Must contain exactly 1 exit (E)
- Must contain at least 1 collectible (C)

### Example Map

```
1111111111111
10010000000C1
1000011111001
1P0011E000001
1111111111111
```

## Installation

### Prerequisites

You need to install MiniLibX and its dependencies:

```bash
# Install required packages
sudo apt-get update
sudo apt-get install gcc make xorg libxext-dev libbsd-dev

# Clone and install MiniLibX
git clone https://github.com/42Paris/minilibx-linux.git
cd minilibx-linux
make
sudo cp libmlx.a /usr/local/lib/
sudo cp libmlx_Linux.a /usr/local/lib/
sudo cp mlx.h /usr/local/include/
```

## Compilation

```bash
make
```

This will compile the project with the following flags:
- `-Wall -Wextra -Werror`
- Links with MiniLibX, X11, and Xext libraries

## Usage

```bash
./so_long <map_file.ber>
```

### Examples

```bash
# Simple map
./so_long maps/simple.ber

# Medium difficulty
./so_long maps/medium.ber

# Large map
./so_long maps/large.ber
```

## Controls

| Key | Action |
|-----|--------|
| W / ↑ | Move up |
| S / ↓ | Move down |
| A / ← | Move left |
| D / → | Move right |
| ESC | Quit game |

## Files

- `main.c` - Entry point and argument parsing
- `init.c` - Game and MiniLibX initialization
- `map_parser.c` - Map file parsing
- `map_validation.c` - Map validation logic
- `game.c` - Game logic (movement, collectibles, exit)
- `render.c` - Graphics rendering
- `events.c` - Keyboard and window event handlers
- `utils.c` - Utility functions
- `get_next_line.c` - Line reading for map parsing
- `so_long.h` - Header file with structures and prototypes
- `Makefile` - Build system

## Implementation Details

### Data Structures

```c
typedef struct s_map
{
    char    **grid;          // 2D map array
    int     width;           // Map width
    int     height;          // Map height
    int     collectibles;    // Total collectibles
    int     player_x;        // Player X position
    int     player_y;        // Player Y position
    int     exit_x;          // Exit X position
    int     exit_y;          // Exit Y position
} t_map;

typedef struct s_game
{
    void    *mlx;            // MiniLibX instance
    void    *win;            // Window instance
    t_map   map;             // Map data
    t_img   img;             // Image buffer
    int     collected;       // Items collected
    int     moves;           // Move counter
    int     game_over;       // Game state
} t_game;
```

### Graphics

The game uses a simple colored tile-based rendering system:
- **Walls**: Dark gray (#2C3E50)
- **Floor**: Light gray (#ECF0F1)
- **Player**: Blue (#3498DB)
- **Collectible**: Orange (#F39C12)
- **Exit**: Green (#27AE60) when all items collected
- **Exit (locked)**: Gray (#95A5A6) when items remain

Each tile is 64x64 pixels.

### Game Flow

1. **Initialization**:
   - Parse command-line arguments
   - Load and validate map
   - Initialize MiniLibX
   - Create game window
   - Render initial state

2. **Game Loop**:
   - Handle keyboard events
   - Update player position
   - Check for collectibles
   - Check win condition
   - Re-render scene

3. **Win Condition**:
   - All collectibles collected
   - Player reaches exit
   - Display victory message and move count

## Error Handling

The program handles various error cases:
- Invalid file extension
- File not found
- Invalid map format
- Map not rectangular
- Missing walls
- Wrong number of players/exits
- No collectibles
- MiniLibX initialization failures

All errors are reported with:
```
Error
<specific error message>
```

## Makefile Rules

- `make` or `make all` - Compile the project
- `make clean` - Remove object files
- `make fclean` - Remove object files and executable
- `make re` - Recompile everything
- `make test` - Compile and run with simple map

## Testing

Test maps are provided in the `maps/` directory:
- `simple.ber` - Small 5x13 map for basic testing
- `medium.ber` - 6x34 map with more complexity
- `large.ber` - 11x45 map for performance testing

### Creating Custom Maps

1. Create a `.ber` file
2. Ensure it's rectangular
3. Surround with walls (1)
4. Add exactly one P and one E
5. Add at least one C
6. Test with: `./so_long your_map.ber`

## Bonus Features (Not Implemented)

Potential enhancements:
- Enemy patrols
- Sprite animations
- On-screen move counter
- Multiple levels
- Timer/scoring system

## Performance

- Efficient tile-based rendering
- Double buffering for smooth graphics
- Minimal memory allocations
- No memory leaks (validated with valgrind)

## Known Limitations

- Requires X11 (Linux/Unix)
- No texture images (uses solid colors)
- Turn-based movement (not real-time)
- Single level only

## Author

Generated for 42 School project

## License

This project is part of the 42 School curriculum.

## Acknowledgments

- 42 School for the project subject
- MiniLibX library developers
