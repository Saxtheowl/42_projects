#!/usr/bin/env python3
"""
ft_turing - Turing Machine Simulator
Universal Turing Machine implementation
"""

import sys
import json
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, field
from enum import Enum


class Direction(Enum):
    LEFT = "LEFT"
    RIGHT = "RIGHT"


@dataclass
class Transition:
    """A transition rule for the Turing machine."""
    read: str           # Symbol to read
    to_state: str       # Next state
    write: str          # Symbol to write
    action: Direction   # Move direction


@dataclass
class TuringMachine:
    """Universal Turing Machine."""
    name: str
    alphabet: List[str]
    blank: str
    states: List[str]
    initial: str
    finals: List[str]
    transitions: Dict[str, List[Transition]]

    # Runtime state
    tape: List[str] = field(default_factory=list)
    head: int = 0
    current_state: str = ""
    step_count: int = 0

    def __post_init__(self):
        self.current_state = self.initial

    def load_input(self, input_str: str):
        """Load input onto the tape."""
        self.tape = list(input_str) if input_str else [self.blank]
        self.head = 0
        self.current_state = self.initial
        self.step_count = 0

    def read_symbol(self) -> str:
        """Read symbol at head position."""
        if self.head < 0:
            self.tape.insert(0, self.blank)
            self.head = 0
        while self.head >= len(self.tape):
            self.tape.append(self.blank)
        return self.tape[self.head]

    def write_symbol(self, symbol: str):
        """Write symbol at head position."""
        while self.head >= len(self.tape):
            self.tape.append(self.blank)
        if self.head < 0:
            self.tape.insert(0, self.blank)
            self.head = 0
        self.tape[self.head] = symbol

    def move_head(self, direction: Direction):
        """Move head left or right."""
        if direction == Direction.LEFT:
            self.head -= 1
        else:
            self.head += 1

    def get_tape_string(self) -> str:
        """Get tape as string with head position marked."""
        if not self.tape:
            return f"[{self.blank}]"

        result = ""
        for i, symbol in enumerate(self.tape):
            if i == self.head:
                result += f"[{symbol}]"
            else:
                result += symbol
        return result

    def find_transition(self) -> Optional[Transition]:
        """Find applicable transition for current state and symbol."""
        symbol = self.read_symbol()

        if self.current_state not in self.transitions:
            return None

        for trans in self.transitions[self.current_state]:
            if trans.read == symbol:
                return trans

        return None

    def step(self) -> bool:
        """Execute one step. Returns False if halted."""
        if self.current_state in self.finals:
            return False

        trans = self.find_transition()
        if trans is None:
            return False

        # Execute transition
        self.write_symbol(trans.write)
        self.move_head(trans.action)
        self.current_state = trans.to_state
        self.step_count += 1

        return True

    def run(self, max_steps: int = 10000, verbose: bool = True) -> bool:
        """Run machine until halt or max steps."""
        if verbose:
            print(f"Running Turing Machine: {self.name}")
            print(f"Initial state: {self.initial}")
            print(f"Final states: {self.finals}")
            print("=" * 60)

        while self.step_count < max_steps:
            if verbose:
                print(f"Step {self.step_count:4d}: State={self.current_state:15s} Tape={self.get_tape_string()}")

            if not self.step():
                break

        accepted = self.current_state in self.finals

        if verbose:
            print("=" * 60)
            print(f"Final state: {self.current_state}")
            print(f"Total steps: {self.step_count}")
            print(f"Result: {'ACCEPTED' if accepted else 'REJECTED/HALTED'}")
            print(f"Final tape: {self.get_tape_string()}")

        return accepted


def parse_machine(config: dict) -> TuringMachine:
    """Parse machine from JSON config."""
    transitions = {}

    for state, rules in config.get("transitions", {}).items():
        transitions[state] = []
        for rule in rules:
            transitions[state].append(Transition(
                read=rule["read"],
                to_state=rule["to_state"],
                write=rule["write"],
                action=Direction.LEFT if rule["action"] == "LEFT" else Direction.RIGHT
            ))

    return TuringMachine(
        name=config.get("name", "Unnamed"),
        alphabet=config.get("alphabet", []),
        blank=config.get("blank", "_"),
        states=config.get("states", []),
        initial=config.get("initial", ""),
        finals=config.get("finals", []),
        transitions=transitions
    )


# Built-in example machines
UNARY_ADD = {
    "name": "unary_add",
    "alphabet": ["1", ".", "+", "=", "_"],
    "blank": "_",
    "states": ["scanright", "addone", "goback", "done"],
    "initial": "scanright",
    "finals": ["done"],
    "transitions": {
        "scanright": [
            {"read": "1", "to_state": "scanright", "write": "1", "action": "RIGHT"},
            {"read": "+", "to_state": "scanright", "write": "1", "action": "RIGHT"},
            {"read": "=", "to_state": "goback", "write": "_", "action": "LEFT"},
            {"read": "_", "to_state": "done", "write": "_", "action": "LEFT"}
        ],
        "goback": [
            {"read": "1", "to_state": "goback", "write": "1", "action": "LEFT"},
            {"read": "_", "to_state": "done", "write": "_", "action": "RIGHT"}
        ]
    }
}

PALINDROME = {
    "name": "palindrome_checker",
    "alphabet": ["0", "1", "x", "_"],
    "blank": "_",
    "states": ["start", "have0", "have1", "match0", "match1", "back", "accept", "reject"],
    "initial": "start",
    "finals": ["accept", "reject"],
    "transitions": {
        "start": [
            {"read": "0", "to_state": "have0", "write": "x", "action": "RIGHT"},
            {"read": "1", "to_state": "have1", "write": "x", "action": "RIGHT"},
            {"read": "x", "to_state": "accept", "write": "x", "action": "RIGHT"},
            {"read": "_", "to_state": "accept", "write": "_", "action": "RIGHT"}
        ],
        "have0": [
            {"read": "0", "to_state": "have0", "write": "0", "action": "RIGHT"},
            {"read": "1", "to_state": "have0", "write": "1", "action": "RIGHT"},
            {"read": "_", "to_state": "match0", "write": "_", "action": "LEFT"},
            {"read": "x", "to_state": "match0", "write": "x", "action": "LEFT"}
        ],
        "have1": [
            {"read": "0", "to_state": "have1", "write": "0", "action": "RIGHT"},
            {"read": "1", "to_state": "have1", "write": "1", "action": "RIGHT"},
            {"read": "_", "to_state": "match1", "write": "_", "action": "LEFT"},
            {"read": "x", "to_state": "match1", "write": "x", "action": "LEFT"}
        ],
        "match0": [
            {"read": "0", "to_state": "back", "write": "x", "action": "LEFT"},
            {"read": "x", "to_state": "accept", "write": "x", "action": "RIGHT"},
            {"read": "1", "to_state": "reject", "write": "1", "action": "RIGHT"}
        ],
        "match1": [
            {"read": "1", "to_state": "back", "write": "x", "action": "LEFT"},
            {"read": "x", "to_state": "accept", "write": "x", "action": "RIGHT"},
            {"read": "0", "to_state": "reject", "write": "0", "action": "RIGHT"}
        ],
        "back": [
            {"read": "0", "to_state": "back", "write": "0", "action": "LEFT"},
            {"read": "1", "to_state": "back", "write": "1", "action": "LEFT"},
            {"read": "x", "to_state": "start", "write": "x", "action": "RIGHT"}
        ]
    }
}

BINARY_INC = {
    "name": "binary_increment",
    "alphabet": ["0", "1", "_"],
    "blank": "_",
    "states": ["right", "add", "carry", "done"],
    "initial": "right",
    "finals": ["done"],
    "transitions": {
        "right": [
            {"read": "0", "to_state": "right", "write": "0", "action": "RIGHT"},
            {"read": "1", "to_state": "right", "write": "1", "action": "RIGHT"},
            {"read": "_", "to_state": "add", "write": "_", "action": "LEFT"}
        ],
        "add": [
            {"read": "0", "to_state": "done", "write": "1", "action": "LEFT"},
            {"read": "1", "to_state": "carry", "write": "0", "action": "LEFT"},
            {"read": "_", "to_state": "done", "write": "1", "action": "LEFT"}
        ],
        "carry": [
            {"read": "0", "to_state": "done", "write": "1", "action": "LEFT"},
            {"read": "1", "to_state": "carry", "write": "0", "action": "LEFT"},
            {"read": "_", "to_state": "done", "write": "1", "action": "LEFT"}
        ]
    }
}


def run_demo():
    """Run demonstration."""
    print("ft_turing - Turing Machine Simulator")
    print("=" * 60)

    # Demo 1: Unary addition
    print("\n[Demo 1] Unary Addition: 111+11=")
    machine = parse_machine(UNARY_ADD)
    machine.load_input("111+11=")
    machine.run()

    # Demo 2: Palindrome checker
    print("\n[Demo 2] Palindrome Check: 10101")
    machine = parse_machine(PALINDROME)
    machine.load_input("10101")
    machine.run()

    print("\n[Demo 3] Palindrome Check: 1010 (not palindrome)")
    machine = parse_machine(PALINDROME)
    machine.load_input("1010")
    machine.run()

    # Demo 3: Binary increment
    print("\n[Demo 4] Binary Increment: 1011 -> 1100")
    machine = parse_machine(BINARY_INC)
    machine.load_input("1011")
    machine.run()

    print("\n[Demo 5] Binary Increment: 111 -> 1000")
    machine = parse_machine(BINARY_INC)
    machine.load_input("111")
    machine.run()


def main():
    """Main entry point."""
    if len(sys.argv) < 2:
        print("ft_turing - Turing Machine Simulator")
        print()
        print("Usage:")
        print("  python ft_turing.py <machine.json> <input>")
        print("  python ft_turing.py --demo")
        print()
        print("Examples:")
        print("  python ft_turing.py unary_add.json '111+11='")
        print("  python ft_turing.py palindrome.json '10101'")
        print()
        print("Machine JSON format:")
        print(json.dumps(UNARY_ADD, indent=2)[:500] + "...")
        return

    if sys.argv[1] == '--demo':
        run_demo()
        return

    # Load machine from file
    try:
        with open(sys.argv[1], 'r') as f:
            config = json.load(f)
    except FileNotFoundError:
        # Try built-in machines
        if sys.argv[1] == "unary_add":
            config = UNARY_ADD
        elif sys.argv[1] == "palindrome":
            config = PALINDROME
        elif sys.argv[1] == "binary_inc":
            config = BINARY_INC
        else:
            print(f"Error: File not found: {sys.argv[1]}")
            return

    machine = parse_machine(config)

    input_str = sys.argv[2] if len(sys.argv) > 2 else ""
    machine.load_input(input_str)
    machine.run()


if __name__ == "__main__":
    main()
