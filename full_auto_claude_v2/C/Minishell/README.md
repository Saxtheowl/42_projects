# Minishell

A 42 school project - Create a simple shell (like bash).

## Description

Minishell is a minimalist shell implementation that replicates the core functionality of bash. It demonstrates deep understanding of processes, file descriptors, parsing, and system programming.

## Features

### Mandatory Features

**Prompt & History:**
- Display a prompt when waiting for a new command
- Working command history (up/down arrows)

**Command Execution:**
- Search and launch executables based on PATH
- Support for relative and absolute paths
- Execute commands with arguments

**Quote Handling:**
- Single quotes `'` prevent interpretation of metacharacters
- Double quotes `"` prevent interpretation except for `$`

**Redirections:**
- `<` - Input redirection
- `>` - Output redirection
- `<<` - Heredoc (read until delimiter)
- `>>` - Append output redirection

**Pipes:**
- `|` - Connect output of one command to input of next

**Environment Variables:**
- `$VAR` - Expand environment variables
- `$?` - Exit status of last command

**Signal Handling:**
- `ctrl-C` - Display new prompt on new line
- `ctrl-D` - Exit shell
- `ctrl-\` - Do nothing

**Built-in Commands:**
- `echo` with option `-n`
- `cd` with relative or absolute path
- `pwd` (no options)
- `export` (no options)
- `unset` (no options)
- `env` (no options or arguments)
- `exit` (no options)

## Compilation

```bash
make        # Compile minishell
make clean  # Remove object files
make fclean # Remove object files and executable
make re     # Recompile from scratch
```

## Usage

```bash
./minishell
```

### Examples

**Basic commands:**
```bash
minishell$ ls -la
minishell$ echo "Hello World"
minishell$ cat file.txt
```

**Redirections:**
```bash
minishell$ cat < input.txt > output.txt
minishell$ ls >> file_list.txt
minishell$ cat << EOF
> line 1
> line 2
> EOF
```

**Pipes:**
```bash
minishell$ ls | grep minishell | wc -l
minishell$ cat file.txt | sort | uniq
```

**Environment variables:**
```bash
minishell$ echo $HOME
minishell$ echo $PATH
minishell$ echo $?
minishell$ export MY_VAR=hello
minishell$ echo $MY_VAR
minishell$ unset MY_VAR
```

**Built-ins:**
```bash
minishell$ pwd
minishell$ cd /tmp
minishell$ pwd
minishell$ env
minishell$ export TEST=value
minishell$ unset TEST
minishell$ exit
```

**Complex commands:**
```bash
minishell$ cat Makefile | grep "^NAME" | cut -d '=' -f 2
minishell$ echo "test" > file && cat < file | grep test
```

## Architecture

### Modules

1. **Lexer** (`lexer.c`)
   - Tokenizes input into words, operators, and redirections
   - Handles quote parsing

2. **Parser** (`parser.c`)
   - Converts tokens into command structures
   - Builds pipeline with redirections

3. **Expander** (`expander.c`)
   - Expands environment variables
   - Handles `$VAR` and `$?`

4. **Executor** (`executor.c`)
   - Executes commands
   - Handles pipes and forks
   - Finds executables in PATH

5. **Redirections** (`redirections.c`)
   - Sets up input/output redirections
   - Handles heredoc

6. **Built-ins** (`builtin_*.c`)
   - Implements all 7 required built-in commands

7. **Environment** (`env.c`, `env2.c`)
   - Manages environment variables
   - Converts between linked list and array formats

8. **Signals** (`signals.c`)
   - Handles ctrl-C, ctrl-D, ctrl-\
   - Different handling for interactive mode and execution

## Technical Details

### Data Structures

**Token:**
```c
typedef struct s_token {
    t_token_type    type;    // WORD, PIPE, REDIR_IN, etc.
    char            *value;  // Token string value
    struct s_token  *next;
}   t_token;
```

**Command:**
```c
typedef struct s_cmd {
    char            **args;     // Command and arguments
    t_redir         *redirs;    // List of redirections
    struct s_cmd    *next;      // Next command in pipeline
}   t_cmd;
```

**Environment:**
```c
typedef struct s_env {
    char            *key;       // Variable name
    char            *value;     // Variable value
    struct s_env    *next;
}   t_env;
```

### Signal Handling

**Interactive mode:**
- SIGINT (ctrl-C): Print newline and new prompt
- SIGQUIT (ctrl-\): Ignored

**Execution mode:**
- SIGINT (ctrl-C): Terminates child process
- SIGQUIT (ctrl-\): Terminates with core dump

**Heredoc mode:**
- SIGINT (ctrl-C): Exits heredoc and returns to prompt

### Error Handling

- Unclosed quotes: Syntax error
- Invalid redirections: Error message with file name
- Command not found: 127 exit status
- Permission denied: 126 exit status
- Syntax errors: Appropriate error messages

## Requirements

- **Compiler:** gcc/cc
- **Libraries:** readline
- **OS:** Linux/Unix-like system

### Installing readline

**Ubuntu/Debian:**
```bash
sudo apt-get install libreadline-dev
```

**macOS:**
```bash
brew install readline
```

## Memory Management

- No memory leaks in user code
- All heap allocations properly freed
- `readline()` leaks are acceptable (library issue)
- Careful management of file descriptors

## Limitations

- Only one global variable allowed (used for signal handling)
- No support for backslash `\` or semicolon `;`
- Unclosed quotes are not handled
- Built-ins accept no options (except `echo -n`)
- Limited to the features described in the subject

## Testing

Test various scenarios:
- Single commands
- Commands with multiple arguments
- Pipes with multiple commands
- All types of redirections
- Heredoc with different delimiters
- Environment variable expansion
- Quote handling (single and double)
- Signal handling (ctrl-C, ctrl-D, ctrl-\)
- All built-in commands
- Error cases

## Author

Generated for 42 School project

## References

- [GNU Bash Manual](https://www.gnu.org/software/bash/manual/)
- [POSIX Shell Command Language](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html)
- Use `bash` as reference for expected behavior
