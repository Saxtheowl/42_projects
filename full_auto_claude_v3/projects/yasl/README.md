# YASL - Yet Another Scripting Language

A simple interpreted scripting language.

## Features

- Variables with `let`
- Functions with `fn`
- Control flow: `if`, `else`, `while`
- Operators: `+`, `-`, `*`, `/`, `%`, `==`, `!=`, `<`, `>`, `and`, `or`
- Arrays with indexing
- Built-in functions: `len`, `str`, `int`, `float`, `abs`, `min`, `max`
- Print and input
- Comments with `#`

## Usage

```bash
# Run script
python yasl.py script.yasl

# Run demo
python yasl.py demo

# Interactive REPL
python yasl.py repl
```

## Syntax

```javascript
# Variables
let x = 42
let name = "Hello"

# Functions
fn add(a, b) {
    return a + b
}

# Control flow
if (x > 10) {
    print "Big"
} else {
    print "Small"
}

while (x > 0) {
    x = x - 1
}

# Arrays
let arr = [1, 2, 3]
print arr[0]
print len(arr)

# Print
print "Hello, World!"
```

## Built-in Functions

| Function | Description |
|----------|-------------|
| `len(x)` | Length of string/array |
| `str(x)` | Convert to string |
| `int(x)` | Convert to integer |
| `float(x)` | Convert to float |
| `abs(x)` | Absolute value |
| `min(...)` | Minimum value |
| `max(...)` | Maximum value |
| `print` | Print to stdout |
| `input(prompt)` | Read from stdin |

## Author

Implementation for 42 curriculum.
