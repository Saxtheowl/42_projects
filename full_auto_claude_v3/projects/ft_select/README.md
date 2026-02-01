# ft_select - Terminal Argument Selector

Interactive terminal-based argument selection tool.

## Features

- Arrow key navigation
- Multi-column display
- Space to toggle selection
- Delete to remove items
- Terminal resize handling
- Visual highlighting

## Usage

```bash
./ft_select arg1 arg2 arg3 ...
```

## Controls

| Key | Action |
|-----|--------|
| ↑↓←→ | Move cursor |
| Space | Toggle selection |
| Enter | Confirm and output |
| Delete | Remove from list |
| Q/Esc | Quit |

## Building

```bash
make
```

## Output

Selected arguments are printed space-separated on stdout.

## Example

```bash
./ft_select *.c
# Navigate, select files, press Enter
# Selected files printed to stdout
```

## Author

Implementation for 42 curriculum.
