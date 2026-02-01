# ft_ls

A reimplementation of the Unix `ls` command.

## Description

This project recreates the `ls` command with support for the most common options. It lists directory contents with optional detailed information, recursive listing, and various sorting methods.

## Features

- List directory contents
- Long format display (-l)
- Recursive listing (-R)
- Show hidden files (-a)
- Reverse sort order (-r)
- Sort by modification time (-t)

## Options

| Option | Description |
|--------|-------------|
| `-l` | Long format (permissions, links, owner, group, size, date, name) |
| `-R` | Recursive listing of subdirectories |
| `-a` | Show all files including hidden (starting with .) |
| `-r` | Reverse sort order |
| `-t` | Sort by modification time (newest first) |

## Compilation

```bash
make
```

## Usage

```bash
# Basic listing
./ft_ls

# Long format
./ft_ls -l

# Show hidden files
./ft_ls -a

# Recursive listing
./ft_ls -R

# Sort by time, reversed
./ft_ls -tr

# Combine options
./ft_ls -laRt directory/
```

## Example Output

```bash
$ ./ft_ls -l
total 64
-rw-rw-r-- 1 user user   388 Jan 31 22:29 Makefile
-rwxrwxr-x 1 user user 21864 Jan 31 22:29 ft_ls
drwxrwxr-x 2 user user  4096 Jan 31 22:29 src

$ ./ft_ls -la
total 72
drwxrwxr-x 3 user user  4096 Jan 31 22:29 .
drwxrwxr-x 5 user user  4096 Jan 31 22:20 ..
-rw-rw-r-- 1 user user   388 Jan 31 22:29 Makefile
-rwxrwxr-x 1 user user 21864 Jan 31 22:29 ft_ls
drwxrwxr-x 2 user user  4096 Jan 31 22:29 src
```

## Long Format Fields

The `-l` option displays:
1. File type and permissions (e.g., `-rwxr-xr-x`)
2. Number of hard links
3. Owner name
4. Group name
5. File size in bytes
6. Modification time
7. File/directory name (with symlink target if applicable)

## File Type Indicators

| Symbol | Type |
|--------|------|
| `-` | Regular file |
| `d` | Directory |
| `l` | Symbolic link |
| `c` | Character device |
| `b` | Block device |
| `p` | FIFO (named pipe) |
| `s` | Socket |

## Allowed Functions

- `write`, `opendir`, `readdir`, `closedir`
- `stat`, `lstat`, `getpwuid`, `getgrgid`
- `listxattr`, `getxattr`, `time`, `ctime`
- `readlink`, `malloc`, `free`, `perror`, `strerror`, `exit`

## Author

Implementation for 42 curriculum.
