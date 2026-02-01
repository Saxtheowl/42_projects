# Corewar

A programming game where programs (warriors) battle in virtual memory.

## Description

Corewar is a game where two or more programs compete for control of a virtual memory arena. Each program tries to stay alive and eliminate opponents.

## Components

- **Assembler (asm.py)**: Compiles `.s` assembly files to `.cor` binary
- **Virtual Machine (vm.py)**: Executes champions in the arena

## Usage

```bash
# Assemble a warrior
python3 src/asm.py warriors/zork.s

# Run a battle
python3 src/vm.py zork.cor

# Demo mode
python3 src/vm.py --demo
```

## Assembly Language

| Opcode | Description | Cycles |
|--------|-------------|--------|
| `live %n` | Declare player alive | 10 |
| `ld src, reg` | Load value | 5 |
| `st reg, dst` | Store value | 5 |
| `add r1, r2, r3` | Addition | 10 |
| `sub r1, r2, r3` | Subtraction | 10 |
| `and/or/xor` | Bitwise operations | 6 |
| `zjmp %addr` | Jump if zero | 20 |
| `fork %addr` | Create process | 800 |

## Example Warrior

```asm
.name "Simple"
.comment "Basic warrior"

loop:
    live %1
    zjmp %:loop
```

## Files

| File | Description |
|------|-------------|
| `src/vm.py` | Virtual Machine |
| `src/asm.py` | Assembler |
| `warriors/*.s` | Sample warriors |

## Author

Implementation for 42 curriculum.
