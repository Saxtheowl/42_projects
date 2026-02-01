# nm-otool - ELF Binary Analysis Tools

Reimplementation of nm and otool/objdump for ELF binaries.

## Components

### ft_nm

Lists symbols from object files.

```bash
./ft_nm <file>
```

### ft_otool

Displays section contents from object files.

```bash
./ft_otool [-t] [-h] <file>
```

Options:
- `-t` - Show only .text section
- `-h` - Show ELF header info

## Building

```bash
make
```

## Symbol Types (ft_nm)

| Type | Description |
|------|-------------|
| T/t | Text (code) section |
| D/d | Data section |
| B/b | BSS section |
| R/r | Read-only data |
| U | Undefined |
| W/w | Weak symbol |
| A | Absolute |
| C | Common |

Uppercase = global, lowercase = local

## Examples

```bash
# List symbols
./ft_nm /bin/ls

# Show .text section hex dump
./ft_otool -t /bin/ls

# Show ELF header
./ft_otool -h /bin/ls
```

## Author

Implementation for 42 curriculum.
