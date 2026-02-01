# death - Exception and Signal Handling

Robust error handling and crash recovery demonstration in C.

## Features

- Signal handling (SIGSEGV, SIGFPE, etc.)
- Stack trace printing
- Crash recovery with setjmp/longjmp
- TRY-CATCH macros for C
- Resource cleanup with atexit

## Building

```bash
make
```

## Usage

```bash
./death         # Show help
./death 1       # Segfault recovery
./death 2       # Division by zero recovery
./death 3       # Safe operation
```

## Tests

```bash
make test       # Run all tests
```

## Signal Handling

Catches and handles:
- `SIGSEGV` - Segmentation fault
- `SIGFPE` - Floating point exception
- `SIGILL` - Illegal instruction
- `SIGBUS` - Bus error
- `SIGABRT` - Abort

## TRY-CATCH Macros

```c
TRY
{
    // Dangerous code
    cause_segfault();
}
CATCH(sig)
{
    // Recovery code
    printf("Caught signal %d\n", sig);
}
END_TRY;
```

## Stack Trace

On crash, prints full stack trace:
```
=== Stack Trace ===
  [0] ./death(print_stack_trace+0x2e)
  [1] ./death(fatal_signal_handler+0x8a)
  [2] /lib/x86_64-linux-gnu/libc.so.6(+0x42520)
  [3] ./death(cause_segfault+0x14)
  [4] ./death(main+0x156)
  [5] /lib/x86_64-linux-gnu/libc.so.6(__libc_start_main+0xf3)
===================
```

## Resource Management

Resources are tracked and cleaned up:
```c
push_resource(res);  // Track resource
// ... code that might crash ...
// Resources freed via atexit
```

## Compilation Flags

- `-g` - Debug symbols
- `-rdynamic` - Export symbols for backtrace

## Author

Implementation for 42 curriculum.
