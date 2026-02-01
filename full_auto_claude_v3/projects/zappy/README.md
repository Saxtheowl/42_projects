# Zappy - Network Multiplayer Game

Server-client game with AI players and resource collection.

## Features

- TCP server with multiple clients
- Team-based gameplay
- Resource collection
- Player leveling (incantation)
- Vision system
- World wrapping

## Usage

```bash
# Run demo
python3 zappy.py demo

# Start server
python3 zappy.py server 4242 20 20 team1 team2 team3
```

## Server Arguments

```
python3 zappy.py server <port> <width> <height> <teams...>
```

- `port`: TCP port to listen on
- `width`: Map width
- `height`: Map height
- `teams`: Space-separated team names

## Client Commands

| Command | Description |
|---------|-------------|
| `forward` | Move forward |
| `right` | Turn right 90° |
| `left` | Turn left 90° |
| `look` | See surroundings |
| `inventory` | Check inventory |
| `take <obj>` | Pick up object |
| `set <obj>` | Put down object |
| `incantation` | Level up |
| `broadcast <msg>` | Send message |
| `connect_nbr` | Team slots |
| `fork` | Create egg |
| `eject` | Push players |

## Resources

| Resource | Rarity |
|----------|--------|
| food | Common |
| linemate | Common |
| deraumere | Uncommon |
| sibur | Uncommon |
| mendiane | Rare |
| phiras | Rare |
| thystame | Very rare |

## Elevation

Level up requires resources + players:

| Level | Resources | Players |
|-------|-----------|---------|
| 2 | 1 linemate | 1 |
| 3 | 1 linemate, 1 deraumere, 1 sibur | 2 |
| 4 | 2 linemate, 1 sibur, 2 phiras | 2 |
| ... | More resources | More players |
| 8 | Many resources | 6 players |

## Protocol

1. Server sends: `WELCOME\n`
2. Client sends: `<team_name>\n`
3. Server sends: `<client_num>\n<X> <Y>\n`
4. Client sends commands
5. Server responds with results

## Author

Implementation for 42 curriculum.
