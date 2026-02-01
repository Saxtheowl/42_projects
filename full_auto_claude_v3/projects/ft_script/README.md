# ft_script - Terminal Session Recorder

Records terminal sessions to a typescript file, like the Unix `script` command.

## Features

- Record terminal sessions
- Append mode
- Timing file for playback
- Run specific commands
- Quiet mode

## Usage

```bash
# Basic usage (records to 'typescript')
./ft_script

# Record to specific file
./ft_script session.log

# Append to existing file
./ft_script -a session.log

# Record timing for playback
./ft_script -t timing.txt session.log

# Run specific command
./ft_script -c "ls -la" output.txt

# Quiet mode
./ft_script -q session.log
```

## Building

```bash
make
```

## Options

| Option | Description |
|--------|-------------|
| `-a` | Append to output file |
| `-q` | Quiet mode |
| `-t file` | Write timing data |
| `-c cmd` | Run command instead of shell |
| `-h` | Show help |

## How It Works

1. Creates a pseudo-terminal (PTY)
2. Forks a child process running the shell
3. Parent captures all I/O through the PTY
4. Writes output to typescript file

## Author

Implementation for 42 curriculum.
