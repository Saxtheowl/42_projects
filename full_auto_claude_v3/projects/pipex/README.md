# Pipex

## Description

Pipex reproduces the behavior of the shell pipe. It takes two commands and executes them with a pipe between them, reading input from a file and writing output to another file.

The program replicates:
```bash
< file1 cmd1 | cmd2 > file2
```

## Concepts

- **pipe()**: Creates a unidirectional data channel for inter-process communication
- **fork()**: Creates a child process
- **dup2()**: Duplicates file descriptors for stdin/stdout redirection
- **execve()**: Executes a program, replacing the current process image
- **waitpid()**: Waits for child process to terminate

## Compilation

```bash
make
```

## Usage

```bash
./pipex file1 cmd1 cmd2 file2
```

This is equivalent to:
```bash
< file1 cmd1 | cmd2 > file2
```

## Examples

```bash
# Cat a file and grep for a pattern
./pipex infile "cat" "grep hello" outfile
# Equivalent to: < infile cat | grep hello > outfile

# Count words in a file
./pipex infile "cat" "wc -w" outfile
# Equivalent to: < infile cat | wc -w > outfile

# List files and count lines
echo "test" > infile
./pipex infile "cat" "wc -l" outfile
cat outfile  # Output: 1
```

## Testing

```bash
# Create a test file
echo -e "Hello World\nHello Claude\nGoodbye World" > test.txt

# Test 1: grep and wc
./pipex test.txt "grep Hello" "wc -l" result.txt
cat result.txt  # Should output 2

# Test 2: Compare with shell
< test.txt grep Hello | wc -l > expected.txt
diff result.txt expected.txt  # Should be empty (identical)

# Test 3: Error handling
./pipex nonexistent.txt "cat" "wc" out.txt  # Should show error
./pipex test.txt "invalidcmd" "wc" out.txt  # Should show command not found
```

## Author

Implementation for 42 curriculum.
