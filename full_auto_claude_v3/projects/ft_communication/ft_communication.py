#!/usr/bin/env python3
"""
ft_communication - Inter-Process Communication
Demonstration of various IPC mechanisms
"""

import sys
import os
import signal
import struct
import mmap
import multiprocessing
from multiprocessing import Process, Queue, Pipe, Value, Array
import time


# =============================================================
# 1. Signals
# =============================================================

def signal_demo():
    """Demonstrate signal-based communication."""
    print("\n[1] Signal Communication")
    print("-" * 40)

    received = {"count": 0}

    def handler(signum, frame):
        received["count"] += 1
        print(f"  Received signal {signum}")

    signal.signal(signal.SIGUSR1, handler)

    pid = os.fork()
    if pid == 0:
        # Child sends signals
        time.sleep(0.1)
        os.kill(os.getppid(), signal.SIGUSR1)
        time.sleep(0.1)
        os.kill(os.getppid(), signal.SIGUSR1)
        os._exit(0)
    else:
        # Parent receives
        os.wait()
        print(f"  Total signals received: {received['count']}")


# =============================================================
# 2. Pipes
# =============================================================

def pipe_demo():
    """Demonstrate pipe communication."""
    print("\n[2] Pipe Communication")
    print("-" * 40)

    # Anonymous pipe
    read_fd, write_fd = os.pipe()

    pid = os.fork()
    if pid == 0:
        # Child writes
        os.close(read_fd)
        os.write(write_fd, b"Hello from child!")
        os.close(write_fd)
        os._exit(0)
    else:
        # Parent reads
        os.close(write_fd)
        data = os.read(read_fd, 1024)
        os.close(read_fd)
        os.wait()
        print(f"  Received: {data.decode()}")


# =============================================================
# 3. Named Pipes (FIFOs)
# =============================================================

def fifo_demo():
    """Demonstrate FIFO communication."""
    print("\n[3] FIFO (Named Pipe) Communication")
    print("-" * 40)

    fifo_path = "/tmp/ft_comm_fifo"

    # Create FIFO
    try:
        os.mkfifo(fifo_path)
    except FileExistsError:
        pass

    pid = os.fork()
    if pid == 0:
        # Child writes
        time.sleep(0.1)  # Let parent open first
        fd = os.open(fifo_path, os.O_WRONLY)
        os.write(fd, b"Message via FIFO!")
        os.close(fd)
        os._exit(0)
    else:
        # Parent reads
        fd = os.open(fifo_path, os.O_RDONLY)
        data = os.read(fd, 1024)
        os.close(fd)
        os.wait()
        os.unlink(fifo_path)
        print(f"  Received: {data.decode()}")


# =============================================================
# 4. Shared Memory
# =============================================================

def shared_memory_demo():
    """Demonstrate shared memory."""
    print("\n[4] Shared Memory Communication")
    print("-" * 40)

    # Create shared memory file
    shm_path = "/tmp/ft_comm_shm"
    size = 1024

    # Create file for mmap
    with open(shm_path, "wb") as f:
        f.write(b'\x00' * size)

    # Open for mmap
    fd = os.open(shm_path, os.O_RDWR)
    mm = mmap.mmap(fd, size)

    pid = os.fork()
    if pid == 0:
        # Child writes
        time.sleep(0.1)
        message = b"Shared memory message!"
        mm[:len(message)] = message
        mm.close()
        os._exit(0)
    else:
        # Parent reads
        time.sleep(0.2)
        data = mm[:50]
        null_idx = data.find(b'\x00')
        if null_idx > 0:
            data = data[:null_idx]
        mm.close()
        os.close(fd)
        os.unlink(shm_path)
        os.wait()
        print(f"  Received: {data.decode()}")


# =============================================================
# 5. Message Queues (using multiprocessing)
# =============================================================

def message_queue_demo():
    """Demonstrate message queue."""
    print("\n[5] Message Queue Communication")
    print("-" * 40)

    queue = Queue()

    def sender(q):
        q.put("Message 1")
        q.put({"type": "data", "value": 42})
        q.put("END")

    def receiver(q):
        messages = []
        while True:
            msg = q.get()
            if msg == "END":
                break
            messages.append(msg)
        return messages

    # Send
    p = Process(target=sender, args=(queue,))
    p.start()
    p.join()

    # Receive
    while not queue.empty():
        msg = queue.get()
        if msg != "END":
            print(f"  Received: {msg}")


# =============================================================
# 6. Multiprocessing Pipe
# =============================================================

def multiprocess_pipe_demo():
    """Demonstrate multiprocessing pipe."""
    print("\n[6] Multiprocessing Pipe")
    print("-" * 40)

    parent_conn, child_conn = Pipe()

    def child_process(conn):
        conn.send("Hello from child process!")
        conn.send([1, 2, 3, 4, 5])
        conn.close()

    p = Process(target=child_process, args=(child_conn,))
    p.start()

    print(f"  Received: {parent_conn.recv()}")
    print(f"  Received: {parent_conn.recv()}")

    p.join()


# =============================================================
# 7. Shared Value and Array
# =============================================================

def shared_value_demo():
    """Demonstrate shared value and array."""
    print("\n[7] Shared Value and Array")
    print("-" * 40)

    # Shared counter
    counter = Value('i', 0)
    # Shared array
    arr = Array('d', [0.0, 0.0, 0.0])

    def worker(num, counter, arr):
        for _ in range(10):
            with counter.get_lock():
                counter.value += 1
            arr[num % 3] += 1.0
            time.sleep(0.01)

    processes = []
    for i in range(4):
        p = Process(target=worker, args=(i, counter, arr))
        processes.append(p)
        p.start()

    for p in processes:
        p.join()

    print(f"  Counter: {counter.value}")
    print(f"  Array: {list(arr)}")


# =============================================================
# 8. Sockets (Unix Domain)
# =============================================================

def socket_demo():
    """Demonstrate Unix domain socket."""
    print("\n[8] Unix Domain Socket")
    print("-" * 40)

    import socket

    sock_path = "/tmp/ft_comm_socket"

    # Remove if exists
    try:
        os.unlink(sock_path)
    except FileNotFoundError:
        pass

    pid = os.fork()
    if pid == 0:
        # Child: client
        time.sleep(0.2)
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.connect(sock_path)
        client.send(b"Hello via Unix socket!")
        client.close()
        os._exit(0)
    else:
        # Parent: server
        server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server.bind(sock_path)
        server.listen(1)

        conn, _ = server.accept()
        data = conn.recv(1024)
        conn.close()
        server.close()
        os.unlink(sock_path)

        os.wait()
        print(f"  Received: {data.decode()}")


# =============================================================
# Main
# =============================================================

def main():
    print("ft_communication - IPC Demonstration")
    print("=" * 50)

    if len(sys.argv) > 1 and sys.argv[1] == '--help':
        print()
        print("Usage: python ft_communication.py")
        print()
        print("Demonstrates:")
        print("  1. Signals")
        print("  2. Pipes")
        print("  3. FIFOs (Named Pipes)")
        print("  4. Shared Memory")
        print("  5. Message Queues")
        print("  6. Multiprocessing Pipes")
        print("  7. Shared Values/Arrays")
        print("  8. Unix Domain Sockets")
        return

    signal_demo()
    pipe_demo()
    fifo_demo()
    shared_memory_demo()
    message_queue_demo()
    multiprocess_pipe_demo()
    shared_value_demo()
    socket_demo()

    print("\n" + "=" * 50)
    print("All IPC demos complete!")


if __name__ == "__main__":
    main()
