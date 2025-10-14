# Pipex

A 42 school project that reproduces the behavior of shell pipes.

## Description

Pipex is a program that mimics the behavior of the Unix pipe `|` operator. It takes input from a file, passes it through one or more commands, and writes the output to another file.

## Compilation

```bash
make
```

This will create the `pipex` executable.

## Usage

### Basic Usage (Mandatory)

```bash
./pipex file1 cmd1 cmd2 file2
```

This is equivalent to:
```bash
< file1 cmd1 | cmd2 > file2
```

**Example:**
```bash
./pipex infile "ls -l" "wc -l" outfile
# Equivalent to: < infile ls -l | wc -l > outfile
```

### Multiple Pipes (Bonus)

```bash
./pipex file1 cmd1 cmd2 cmd3 ... cmdn file2
```

This is equivalent to:
```bash
< file1 cmd1 | cmd2 | cmd3 | ... | cmdn > file2
```

**Example:**
```bash
./pipex infile "cat" "grep a" "wc -l" outfile
# Equivalent to: < infile cat | grep a | wc -l > outfile
```

### Here_doc (Bonus)

```bash
./pipex here_doc LIMITER cmd1 cmd2 file
```

This is equivalent to:
```bash
cmd1 << LIMITER | cmd2 >> file
```

**Example:**
```bash
./pipex here_doc EOF "grep a" "wc -w" outfile
# Type your input, then type EOF to end
```

## Implementation Details

### Core Functionality
- **Process Management**: Uses `fork()` to create child processes
- **Pipes**: Uses `pipe()` to create pipes between processes
- **I/O Redirection**: Uses `dup2()` to redirect stdin/stdout
- **Command Execution**: Uses `execve()` to execute commands
- **PATH Resolution**: Searches through `$PATH` environment variable to find executables

### File Structure
- `pipex.c` - Main implementation for basic 2-command piping
- `pipex_bonus.c` - Extended implementation for multiple pipes
- `here_doc_bonus.c` - Here_doc functionality
- `utils.c` - Utility functions (error handling, string operations)
- `ft_split.c` - String splitting for command parsing
- `path.c` - PATH environment variable parsing and command lookup
- `pipex.h` - Header file with all declarations

### Error Handling
- Invalid file descriptors
- Command not found errors
- Pipe creation failures
- Fork failures
- Memory allocation errors

## Testing

Basic test:
```bash
echo "Hello World" > infile
./pipex infile "cat" "wc -w" outfile
cat outfile  # Should output: 2
```

Multiple pipes test:
```bash
echo -e "line1\nline2\nline3" > infile
./pipex infile "cat" "wc -l" outfile
cat outfile  # Should output: 3
```

Here_doc test:
```bash
./pipex here_doc END "cat" "wc -w" outfile
# Type: hello world
# Type: END
cat outfile  # Should output: 2
```

## Memory Management

All dynamically allocated memory is properly freed. The program handles:
- Split string arrays from `ft_split()`
- Path strings from `find_path()`
- Proper cleanup on error conditions

## Exit Codes

- `0` - Success
- `1` - General errors (file opening, pipe/fork failures)
- `127` - Command not found

## Author

Generated for 42 School project
