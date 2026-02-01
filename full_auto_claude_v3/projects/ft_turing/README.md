# ft_turing - Turing Machine Simulator

Universal Turing Machine implementation in Python.

## Features

- JSON-based machine definition
- Step-by-step execution with tape visualization
- Built-in example machines
- Accept/reject states
- Infinite tape simulation

## Usage

```bash
python3 ft_turing.py --demo              # Run demos
python3 ft_turing.py machine.json input  # Run machine
python3 ft_turing.py unary_add "111+11=" # Built-in machine
```

## Built-in Machines

| Machine | Description |
|---------|-------------|
| `unary_add` | Unary addition (111+11= -> 11111) |
| `palindrome` | Check if binary string is palindrome |
| `binary_inc` | Increment binary number |

## Machine JSON Format

```json
{
  "name": "machine_name",
  "alphabet": ["0", "1", "_"],
  "blank": "_",
  "states": ["s1", "s2", "halt"],
  "initial": "s1",
  "finals": ["halt"],
  "transitions": {
    "s1": [
      {"read": "0", "to_state": "s2", "write": "1", "action": "RIGHT"},
      {"read": "1", "to_state": "s1", "write": "0", "action": "LEFT"}
    ]
  }
}
```

## Transition Fields

| Field | Description |
|-------|-------------|
| `read` | Symbol to match at head |
| `to_state` | Next state |
| `write` | Symbol to write |
| `action` | HEAD or RIGHT |

## Example Output

```
Running Turing Machine: binary_increment
Initial state: right
Final states: ['done']
============================================================
Step    0: State=right           Tape=[1]011
Step    1: State=right           Tape=1[0]11
Step    2: State=right           Tape=10[1]1
Step    3: State=right           Tape=101[1]
Step    4: State=right           Tape=1011[_]
Step    5: State=add             Tape=101[1]_
Step    6: State=carry           Tape=10[1]0_
Step    7: State=carry           Tape=1[0]00_
Step    8: State=done            Tape=[1]100_
============================================================
Final state: done
Total steps: 8
Result: ACCEPTED
Final tape: [1]100_
```

## Author

Implementation for 42 curriculum.
