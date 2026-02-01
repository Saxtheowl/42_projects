# Dr_Quine

Self-replicating programs in C.

## Description

This project implements quines - programs that output their own source code.

## Programs

### Colleen
A proper quine that outputs its own source code to stdout.

```bash
./Colleen > output.c
diff Colleen.c output.c  # Should be identical
```

### Grace
Similar to Colleen, but includes its own filename in the source.

```bash
./Grace > output.c
diff Grace.c output.c  # Should be identical
```

### Sully
Self-replicating program that creates a copy of itself as `Sully_1.c`.

```bash
./Sully
diff Sully.c Sully_1.c  # Should be identical
```

## Compilation

```bash
make        # Build all quines
make test   # Test all quines
make clean  # Remove generated files
```

## How Quines Work

A quine works by containing its own source as data and a function that prints both the data (as code) and the data (as a string literal).

The key technique is to use format specifiers:
- `%s` to insert the data string itself
- `%c` with ASCII values (34 for `"`, 10 for newline) for special characters

Example structure:
```c
char*s="<format string containing %s>";
int main(){printf(s,s);}  // Print format with data as argument
```

## Constraints

- No reading the source file
- No hardcoded source as comments
- Must compile with -Wall -Wextra -Werror

## Author

Implementation for 42 curriculum.
