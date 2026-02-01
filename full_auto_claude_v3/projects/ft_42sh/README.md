# ft_42sh - Advanced Shell

Full-featured POSIX-compliant shell with job control.

## Features

- Command execution
- Pipes (`|`)
- Logical operators (`&&`, `||`)
- Command chaining (`;`)
- Built-in commands
- Environment variables
- Command history
- Signal handling
- Colored prompt

## Building

```bash
make
./42sh
```

## Built-in Commands

| Command | Description |
|---------|-------------|
| `cd [dir]` | Change directory |
| `pwd` | Print working directory |
| `echo [-n] args` | Print arguments |
| `env` | Show environment |
| `export VAR=val` | Set environment variable |
| `unset VAR` | Remove variable |
| `history` | Show command history |
| `jobs` | List background jobs |
| `exit [code]` | Exit shell |

## Operators

| Operator | Description |
|----------|-------------|
| `\|` | Pipe output to next command |
| `&&` | Execute if previous succeeded |
| `\|\|` | Execute if previous failed |
| `;` | Sequential execution |

## Examples

```bash
# Pipes
ls -la | grep ".c" | wc -l

# Logical operators
make && ./program
./test || echo "Test failed"

# Command chaining
cd /tmp; ls; cd -

# Environment
export MY_VAR="hello"
echo $MY_VAR
```

## Prompt Format

```
42sh:~/current/directory$
```

Shows:
- Shell name in green
- Current directory in blue
- Home directory abbreviated as `~`

## Signal Handling

- `Ctrl+C`: Interrupt current command (not shell)
- `Ctrl+D`: Exit shell (EOF)
- `Ctrl+Z`: Suspend current job

## Author

Implementation for 42 curriculum.
