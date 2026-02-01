# ft_strace / ft_ltrace - System Call Tracer

Trace system calls and library calls using ptrace.

## Features

- System call tracing (strace)
- Syscall name resolution
- Argument display
- Return value display
- x86_64 support

## Building

```bash
make
```

## Usage

```bash
./ft_strace /bin/ls -la
./ft_strace /bin/echo hello
```

## Example Output

```
execve(0x7ffe..., 0x7ffe..., 0x7ffe...) = 0x0
brk(0x0, 0x0, 0x0) = 0x55555...
access(0x7f..., 0x4, 0x0) = 0xffffffff
openat(0xffffff9c, 0x7f..., 0x80000) = 0x3
fstat(0x3, 0x7ffd..., 0x7f...) = 0x0
mmap(0x0, 0x1234, 0x1) = 0x7f...
close(0x3, 0x7f..., 0x0) = 0x0
...
write(0x1, 0x7f..., 0x5) = 0x5
exit_group(0x0, 0x0, 0x0) = ?
+++ exited with 0 +++
```

## Syscall Numbers

Uses x86_64 syscall numbers:
- 0: read
- 1: write
- 2: open
- 3: close
- 9: mmap
- 59: execve
- 60: exit
- etc.

## How It Works

1. Fork child process
2. Child calls `PTRACE_TRACEME`
3. Child execs target program
4. Parent traces with `PTRACE_SYSCALL`
5. On each stop, read registers
6. Display syscall name and args

## Technical Details

- Uses `ptrace()` system call
- Reads registers via `PTRACE_GETREGS`
- `orig_rax` contains syscall number
- `rax` contains return value
- Arguments in rdi, rsi, rdx, r10, r8, r9

## Limitations

- x86_64 only
- Basic argument display
- No string/struct parsing

## Author

Implementation for 42 curriculum.
