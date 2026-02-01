# ft_irc

An IRC server implementation in C++98.

## Description

This project implements an IRC (Internet Relay Chat) server that can be used with any standard IRC client. The server supports multiple clients, channels, and various IRC commands.

## Features

### Connection Management
- TCP/IP socket-based server
- Multiple simultaneous client connections using `select()`
- Non-blocking I/O operations
- Password authentication

### IRC Commands

| Command | Description |
|---------|-------------|
| `PASS` | Authenticate with server password |
| `NICK` | Set or change nickname |
| `USER` | Set username and realname |
| `JOIN` | Join a channel |
| `PART` | Leave a channel |
| `PRIVMSG` | Send message to user or channel |
| `NOTICE` | Send notice to user or channel |
| `KICK` | Kick user from channel (operator only) |
| `INVITE` | Invite user to channel |
| `TOPIC` | View or set channel topic |
| `MODE` | View or set channel modes |
| `QUIT` | Disconnect from server |
| `PING` | Ping server |

### Channel Modes

| Mode | Description |
|------|-------------|
| `i` | Invite-only channel |
| `t` | Topic restricted to operators |
| `k` | Channel key (password) |
| `o` | Channel operator status |
| `l` | User limit |

## Compilation

```bash
make
```

## Usage

### Starting the Server
```bash
./ircserv <port> <password>
```

Example:
```bash
./ircserv 6667 secretpassword
```

### Connecting with a Client

Using netcat (for testing):
```bash
nc localhost 6667
PASS secretpassword
NICK mynick
USER myuser 0 * :My Real Name
```

Using irssi:
```bash
irssi -c localhost -p 6667 -w secretpassword
```

Using HexChat or other GUI clients:
1. Add a new network with server `localhost/6667`
2. Set the password in server settings
3. Connect

## Example Session

```
# Terminal 1: Start server
./ircserv 6667 password123

# Terminal 2: Connect as client
nc localhost 6667
PASS password123
NICK alice
USER alice 0 * :Alice Smith
# Welcome messages received
JOIN #general
PRIVMSG #general :Hello everyone!
PART #general :Goodbye
QUIT :Leaving

# Terminal 3: Another client
nc localhost 6667
PASS password123
NICK bob
USER bob 0 * :Bob Jones
JOIN #general
PRIVMSG alice :Private message to Alice
```

## Architecture

```
ft_irc/
├── src/
│   ├── irc.hpp         # Common includes and defines
│   ├── Client.hpp/cpp  # Client connection handling
│   ├── Channel.hpp/cpp # Channel management
│   ├── Server.hpp/cpp  # Main server logic
│   ├── Commands.cpp    # IRC command implementations
│   └── main.cpp        # Entry point
├── Makefile
└── README.md
```

## Technical Details

### Message Format
- Messages are terminated with `\r\n`
- Maximum message length: 512 bytes
- Prefix format: `:nickname!username@hostname`

### Reply Codes
The server implements standard IRC numeric replies:
- 001-004: Welcome messages
- 331-332: Topic replies
- 353, 366: Names list
- 4xx: Error codes

## Allowed Functions

- `socket`, `close`, `setsockopt`, `getsockname`
- `getprotobyname`, `gethostbyname`
- `getaddrinfo`, `freeaddrinfo`, `bind`
- `connect`, `listen`, `accept`
- `htons`, `htonl`, `ntohs`, `ntohl`
- `inet_addr`, `inet_ntoa`
- `send`, `recv`
- `signal`, `sigaction`
- `lseek`, `fstat`
- `fcntl`, `poll` (or `select`, `kqueue`, `epoll`)

## Testing

You can test the server with multiple terminal windows:

```bash
# Server
./ircserv 6667 test

# Client 1
nc localhost 6667

# Client 2
nc localhost 6667
```

## Author

Implementation for 42 curriculum.
