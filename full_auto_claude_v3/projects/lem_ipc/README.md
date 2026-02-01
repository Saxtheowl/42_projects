# lem_ipc - Inter-Process Communication Game

Multiplayer game using shared memory and semaphores for IPC.

## Features

- Shared memory game state
- Semaphore synchronization
- Team-based gameplay
- Real-time multiplayer
- Combat system

## Building

```bash
make
```

## Usage

```bash
# Terminal 1 - Player on team 1
./lem_ipc 1

# Terminal 2 - Player on team 2
./lem_ipc 2

# Terminal 3 - Another player on team 1 (ally)
./lem_ipc 1
```

## Controls

| Key | Action |
|-----|--------|
| W | Move up |
| A | Move left |
| S | Move down |
| D | Move right |
| Q | Quit |

## Gameplay

- Players on the same team are allies (shown in blue)
- Players on different teams are enemies (shown in red)
- Move into an enemy to attack
- You appear as `@` in green
- Walls are `#`
- Empty spaces are `.`

## IPC Mechanisms

### Shared Memory
- Game state shared between all players
- Map, player positions, scores
- Uses `shmget()`, `shmat()`, `shmdt()`

### Semaphores
- Mutex for synchronizing access
- Prevents race conditions
- Uses `semget()`, `semop()`

## Cleanup

```bash
# Remove IPC resources after game
make ipc_clean

# Or manually
ipcrm -M 0x42424242  # Remove shared memory
ipcrm -S 0x42424243  # Remove semaphore
```

## Technical Details

- Key for shared memory: `0x42424242`
- Key for semaphore: `0x42424243`
- Map size: 20x20
- Max players: 8
- Teams: 1-4

## Author

Implementation for 42 curriculum.
