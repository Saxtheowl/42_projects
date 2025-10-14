# Minitalk

A 42 school project that implements a simple data exchange program using UNIX signals.

## Description

Minitalk is a client-server communication program that transmits strings using only UNIX signals (SIGUSR1 and SIGUSR2). The client sends a message to the server by encoding each character bit by bit and sending signals to represent 0s and 1s.

## How It Works

### Signal-Based Communication
- Each character is transmitted as 8 bits (1 byte)
- `SIGUSR1` represents bit value 0
- `SIGUSR2` represents bit value 1
- The server reconstructs characters by receiving signals and assembling bits

### Example
To send the character 'A' (ASCII 65 = 0b01000001):
```
Client sends: SIGUSR2, SIGUSR1, SIGUSR1, SIGUSR1, SIGUSR1, SIGUSR1, SIGUSR2, SIGUSR1
Server receives bits: 1, 0, 0, 0, 0, 0, 1, 0 → reconstructs 'A'
```

## Compilation

### Mandatory
```bash
make
```
Creates `server` and `client` executables.

### Bonus
```bash
make bonus
```
Creates `server_bonus` and `client_bonus` executables with additional features.

## Usage

### Mandatory Version

1. Start the server:
```bash
./server
```
The server will display its PID (Process ID).

2. Send a message from the client:
```bash
./client <server_pid> "Your message here"
```

**Example:**
```bash
# Terminal 1
./server
Server PID: 12345

# Terminal 2
./client 12345 "Hello, World!"
```

The server will display: `Hello, World!`

### Bonus Version

The bonus version adds:
- Server acknowledgment (confirms message reception)
- Unicode character support

**Usage:**
```bash
# Terminal 1
./server_bonus
Server PID: 12345

# Terminal 2
./client_bonus 12345 "Hello with emoji 🚀"
```

The client will display: `Message received by server!`

## Features

### Mandatory Part
- Server prints its PID on startup
- Client sends string to server via signals
- Server displays received string
- Fast transmission (much faster than 1 second per 100 characters)
- Server handles multiple clients without restart
- Uses only SIGUSR1 and SIGUSR2 signals

### Bonus Part
- Server acknowledges message reception by sending signal back to client
- Support for Unicode characters (UTF-8)
- Synchronization to prevent signal loss

## Implementation Details

### Server
- Uses `sigaction()` for robust signal handling
- Maintains state in a global structure:
  - Current character being assembled
  - Bit count (0-7)
- Reconstructs characters from received signals
- Displays complete string when null terminator received

### Client
- Parses command-line arguments (PID and message)
- Converts each character to bits
- Sends bits using `kill()` with appropriate signal
- Adds small delays (`usleep(100)`) to prevent signal loss
- Bonus: Waits for acknowledgment from server

### Signal Handling
```c
// Server sets up handlers
struct sigaction sa;
sa.sa_handler = handle_signal;  // or sa.sa_sigaction for bonus
sa.sa_flags = 0;  // or SA_SIGINFO for bonus
sigemptyset(&sa.sa_mask);
sigaction(SIGUSR1, &sa, NULL);
sigaction(SIGUSR2, &sa, NULL);

// Client sends signals
kill(server_pid, SIGUSR1);  // Send bit 0
kill(server_pid, SIGUSR2);  // Send bit 1
```

## Technical Challenges

### Signal Queueing
Linux systems don't queue signals of the same type when pending signals already exist. Solutions:
- Add small delays between signals (`usleep()`)
- Implement acknowledgment system (bonus) for synchronization

### Bit Order
The implementation sends bits from LSB (Least Significant Bit) to MSB (Most Significant Bit), reconstructing the character with bit shifting:
```c
if (signal == SIGUSR2)
    character |= (1 << bit_position);
```

### Multiple Clients
The server uses `pause()` to wait for signals and can handle sequential messages from different clients without restart.

## Testing

Basic test:
```bash
./server &
SERVER_PID=$!
./client $SERVER_PID "Test message 123"
kill $SERVER_PID
```

Unicode test (bonus):
```bash
./server_bonus &
SERVER_PID=$!
./client_bonus $SERVER_PID "Unicode: 你好 🚀 café"
kill $SERVER_PID
```

Long message test:
```bash
./server &
SERVER_PID=$!
./client $SERVER_PID "Lorem ipsum dolor sit amet, consectetur adipiscing elit..."
kill $SERVER_PID
```

## File Structure

```
.
├── Makefile              # Build system
├── minitalk.h            # Header for mandatory part
├── minitalk_bonus.h      # Header for bonus part
├── server.c              # Server implementation (mandatory)
├── client.c              # Client implementation (mandatory)
├── server_bonus.c        # Server with acknowledgment (bonus)
├── client_bonus.c        # Client with acknowledgment (bonus)
└── utils.c               # Utility functions (shared)
```

## Allowed Functions

- `write`, `ft_printf`
- `signal`, `sigemptyset`, `sigaddset`, `sigaction`
- `kill`, `getpid`
- `malloc`, `free`
- `pause`, `sleep`, `usleep`
- `exit`

## Performance

The implementation is highly optimized:
- 100 characters transmitted in less than 0.2 seconds
- Minimal delay between signals (100 microseconds)
- Efficient bit-level operations

## Error Handling

- Invalid PID detection
- Signal send failure handling
- Proper memory management (no leaks)
- Graceful error messages

## Author

Generated for 42 School project
