# Minishell

A simple shell implementation in C, as beautiful as a shell.

## Description

Minishell is a basic shell that replicates some of the functionality of bash. It supports command execution, pipes, redirections, environment variables, and several built-in commands.

## Features

### Command Execution
- Execute commands from PATH
- Execute commands with absolute/relative paths
- Handle command arguments

### Pipes
- Chain multiple commands with `|`
- Example: `ls -la | grep txt | wc -l`

### Redirections
- Input redirection: `< file`
- Output redirection: `> file`
- Append redirection: `>> file`
- Here-document: `<< DELIMITER`

### Environment Variables
- Variable expansion with `$VAR`
- Exit status with `$?`
- Supports quotes (single and double)

### Built-in Commands
| Command | Description |
|---------|-------------|
| `echo` | Print arguments (-n flag supported) |
| `cd` | Change directory (-, ~, relative/absolute paths) |
| `pwd` | Print working directory |
| `export` | Set environment variables |
| `unset` | Remove environment variables |
| `env` | Print environment variables |
| `exit` | Exit the shell |

### Signal Handling
- `Ctrl+C` (SIGINT): Interrupt current command / display new prompt
- `Ctrl+\` (SIGQUIT): Ignored in interactive mode
- `Ctrl+D` (EOF): Exit shell

## Compilation

```bash
make
```

Requires the readline library:
```bash
# Debian/Ubuntu
sudo apt-get install libreadline-dev

# macOS
brew install readline
```

## Usage

```bash
./minishell
```

## Examples

```bash
minishell> echo Hello World
Hello World

minishell> ls -la | grep Makefile
-rw-rw-r-- 1 user user  1234 Jan 31 12:00 Makefile

minishell> cat < input.txt > output.txt

minishell> export MY_VAR="Hello"
minishell> echo $MY_VAR
Hello

minishell> echo $?
0

minishell> cd /tmp && pwd
/tmp

minishell> cat << EOF
> Hello
> World
> EOF
Hello
World

minishell> exit
```

## Architecture

```
minishell
├── src/
│   ├── main.c           # Main loop, initialization
│   ├── lexer.c          # Tokenization
│   ├── parser.c         # Command parsing
│   ├── executor.c       # Command execution
│   ├── builtins.c       # Built-in command dispatcher
│   ├── builtin_*.c      # Individual built-in commands
│   ├── env.c            # Environment variable management
│   ├── expand.c         # Variable expansion
│   ├── redirect.c       # Redirection handling
│   ├── signals.c        # Signal handling
│   ├── path.c           # PATH resolution
│   └── utils*.c         # Utility functions
└── Makefile
```

## Allowed Functions

- `readline`, `rl_clear_history`, `rl_on_new_line`, `rl_replace_line`, `rl_redisplay`, `add_history`
- `printf`, `malloc`, `free`, `write`, `access`, `open`, `read`, `close`
- `fork`, `wait`, `waitpid`, `wait3`, `wait4`
- `signal`, `sigaction`, `sigemptyset`, `sigaddset`, `kill`
- `exit`, `getcwd`, `chdir`, `stat`, `lstat`, `fstat`
- `unlink`, `execve`, `dup`, `dup2`, `pipe`
- `opendir`, `readdir`, `closedir`
- `strerror`, `perror`, `isatty`, `ttyname`, `ttyslot`
- `ioctl`, `getenv`, `tcsetattr`, `tcgetattr`, `tgetent`, `tgetflag`, `tgetnum`, `tgetstr`, `tgoto`, `tputs`

## Author

Implementation for 42 curriculum.
