# Minitalk

## Description

Minitalk is a client-server communication program using UNIX signals. The server displays its PID and waits for messages. The client sends a string to the server bit by bit using SIGUSR1 and SIGUSR2 signals.

## Compilation

```bash
make
```

## Usage

1. Start the server:
```bash
./server
# Server PID: 12345
```

2. Send a message from client:
```bash
./client 12345 "Hello, World!"
```

## How It Works

- Each character is sent as 8 bits
- SIGUSR1 represents bit 1
- SIGUSR2 represents bit 0
- The server reconstructs characters from received bits

## Files

- `server.c` - Server that receives and displays messages
- `client.c` - Client that sends messages to server
- `utils.c` - Utility functions
- `minitalk.h` - Header file

## Author

Implementation for 42 curriculum.
