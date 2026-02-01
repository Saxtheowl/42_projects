# ft_communication - Inter-Process Communication

Demonstration of various IPC mechanisms in Python/Unix.

## Features

1. Signals
2. Pipes
3. FIFOs (Named Pipes)
4. Shared Memory
5. Message Queues
6. Multiprocessing Pipes
7. Shared Values/Arrays
8. Unix Domain Sockets

## Usage

```bash
python3 ft_communication.py
```

## IPC Mechanisms

### 1. Signals
- Asynchronous notifications
- SIGUSR1, SIGUSR2 for user signals
- Limited data transfer

### 2. Pipes
- Unidirectional byte stream
- Anonymous (parent-child)
- Uses file descriptors

### 3. FIFOs
- Named pipes with filesystem path
- Any process can connect
- Persistent until removed

### 4. Shared Memory
- Fastest IPC method
- Memory-mapped files
- Requires synchronization

### 5. Message Queues
- Structured messages
- Priority support
- Process decoupling

### 6. Multiprocessing Pipes
- Python's high-level API
- Bidirectional communication
- Object serialization

### 7. Shared Values/Arrays
- Thread-safe primitives
- Lock-protected access
- Direct memory sharing

### 8. Unix Domain Sockets
- Local socket communication
- Stream or datagram
- Efficient for local IPC

## Comparison

| Method | Speed | Complexity | Use Case |
|--------|-------|------------|----------|
| Signals | Fast | Low | Notifications |
| Pipes | Medium | Low | Parent-child |
| FIFOs | Medium | Medium | Any processes |
| Shared Memory | Fastest | High | Large data |
| Message Queues | Medium | Medium | Structured data |
| Sockets | Medium | Medium | Flexible |

## Author

Implementation for 42 curriculum.
