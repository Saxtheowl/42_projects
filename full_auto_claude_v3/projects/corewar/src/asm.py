#!/usr/bin/env python3
"""
Corewar Assembler
Compiles .s assembly files to .cor binary champions.
"""

import sys
import re
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass


OPCODES = {
    'live': (0x01, [('dir', 4)]),
    'ld':   (0x02, [('dir|ind', 4), ('reg', 1)]),
    'st':   (0x03, [('reg', 1), ('reg|ind', 2)]),
    'add':  (0x04, [('reg', 1), ('reg', 1), ('reg', 1)]),
    'sub':  (0x05, [('reg', 1), ('reg', 1), ('reg', 1)]),
    'and':  (0x06, [('reg|dir|ind', 4), ('reg|dir|ind', 4), ('reg', 1)]),
    'or':   (0x07, [('reg|dir|ind', 4), ('reg|dir|ind', 4), ('reg', 1)]),
    'xor':  (0x08, [('reg|dir|ind', 4), ('reg|dir|ind', 4), ('reg', 1)]),
    'zjmp': (0x09, [('dir', 2)]),
    'ldi':  (0x0A, [('reg|dir|ind', 2), ('reg|dir', 2), ('reg', 1)]),
    'sti':  (0x0B, [('reg', 1), ('reg|dir|ind', 2), ('reg|dir', 2)]),
    'fork': (0x0C, [('dir', 2)]),
    'lld':  (0x0D, [('dir|ind', 4), ('reg', 1)]),
    'lldi': (0x0E, [('reg|dir|ind', 2), ('reg|dir', 2), ('reg', 1)]),
    'lfork':(0x0F, [('dir', 2)]),
    'aff':  (0x10, [('reg', 1)]),
}

# Instructions that don't use encoding byte
NO_ENCODING = ['live', 'zjmp', 'fork', 'lfork']


@dataclass
class Instruction:
    op: str
    args: List[Tuple[str, str]]  # (type, value)
    line: int
    offset: int = 0


@dataclass
class Label:
    name: str
    offset: int


class Assembler:
    def __init__(self):
        self.name = ""
        self.comment = ""
        self.instructions: List[Instruction] = []
        self.labels: Dict[str, int] = {}
        self.current_offset = 0
    
    def parse_line(self, line: str, line_num: int):
        """Parse a single line of assembly."""
        # Remove comments
        if '#' in line:
            line = line[:line.index('#')]
        line = line.strip()
        
        if not line:
            return
        
        # Check for .name
        if line.startswith('.name'):
            match = re.search(r'"([^"]*)"', line)
            if match:
                self.name = match.group(1)
            return
        
        # Check for .comment
        if line.startswith('.comment'):
            match = re.search(r'"([^"]*)"', line)
            if match:
                self.comment = match.group(1)
            return
        
        # Check for label
        if ':' in line:
            parts = line.split(':', 1)
            label_name = parts[0].strip()
            self.labels[label_name] = self.current_offset
            line = parts[1].strip() if len(parts) > 1 else ""
            if not line:
                return
        
        # Parse instruction
        parts = line.split(None, 1)
        if not parts:
            return
        
        op = parts[0].lower()
        if op not in OPCODES:
            print(f"Line {line_num}: Unknown opcode '{op}'")
            return
        
        args_str = parts[1] if len(parts) > 1 else ""
        args = self.parse_args(args_str, op)
        
        instr = Instruction(op=op, args=args, line=line_num, offset=self.current_offset)
        self.instructions.append(instr)
        
        # Calculate instruction size
        size = 1  # Opcode
        if op not in NO_ENCODING:
            size += 1  # Encoding byte
        
        opcode_info = OPCODES[op]
        for i, (arg_type, val) in enumerate(args):
            expected_types, default_size = opcode_info[1][i] if i < len(opcode_info[1]) else ('reg', 1)
            if arg_type == 'reg':
                size += 1
            elif arg_type == 'dir':
                size += default_size
            elif arg_type == 'ind':
                size += 2
        
        self.current_offset += size
    
    def parse_args(self, args_str: str, op: str) -> List[Tuple[str, str]]:
        """Parse instruction arguments."""
        if not args_str:
            return []
        
        args = []
        for arg in args_str.split(','):
            arg = arg.strip()
            if not arg:
                continue
            
            if arg.startswith('r'):
                # Register
                args.append(('reg', arg[1:]))
            elif arg.startswith('%:'):
                # Direct label reference
                args.append(('dir', arg[2:]))
            elif arg.startswith('%'):
                # Direct value
                args.append(('dir', arg[1:]))
            elif arg.startswith(':'):
                # Indirect label reference
                args.append(('ind', arg[1:]))
            else:
                # Indirect value
                args.append(('ind', arg))
        
        return args
    
    def resolve_labels(self):
        """Resolve label references to offsets."""
        for instr in self.instructions:
            new_args = []
            for arg_type, value in instr.args:
                if value in self.labels:
                    # Calculate relative offset
                    offset = self.labels[value] - instr.offset
                    new_args.append((arg_type, str(offset)))
                else:
                    new_args.append((arg_type, value))
            instr.args = new_args
    
    def generate_encoding_byte(self, args: List[Tuple[str, str]]) -> int:
        """Generate the encoding byte for an instruction."""
        encoding = 0
        shift = 6
        for arg_type, _ in args:
            if arg_type == 'reg':
                encoding |= (0b01 << shift)
            elif arg_type == 'dir':
                encoding |= (0b10 << shift)
            elif arg_type == 'ind':
                encoding |= (0b11 << shift)
            shift -= 2
        return encoding
    
    def compile(self) -> bytes:
        """Compile to binary."""
        self.resolve_labels()
        
        output = bytearray()
        
        for instr in self.instructions:
            opcode, arg_specs = OPCODES[instr.op]
            output.append(opcode)
            
            # Add encoding byte if needed
            if instr.op not in NO_ENCODING:
                output.append(self.generate_encoding_byte(instr.args))
            
            # Add arguments
            for i, (arg_type, value) in enumerate(instr.args):
                expected_types, default_size = arg_specs[i] if i < len(arg_specs) else ('reg', 1)
                
                try:
                    val = int(value)
                except ValueError:
                    val = 0
                
                if arg_type == 'reg':
                    output.append(val & 0xFF)
                elif arg_type == 'dir':
                    if default_size == 4:
                        output.extend(val.to_bytes(4, 'big', signed=True))
                    else:
                        output.extend((val & 0xFFFF).to_bytes(2, 'big', signed=False))
                elif arg_type == 'ind':
                    output.extend((val & 0xFFFF).to_bytes(2, 'big', signed=False))
        
        return bytes(output)
    
    def create_header(self, code: bytes) -> bytes:
        """Create .cor file header."""
        header = bytearray()
        
        # Magic number
        header.extend([0x00, 0xea, 0x83, 0xf3])
        
        # Name (128 bytes, null-padded)
        name_bytes = self.name.encode('utf-8')[:127]
        header.extend(name_bytes)
        header.extend([0] * (128 - len(name_bytes)))
        
        # Null separator
        header.extend([0, 0, 0, 0])
        
        # Code size
        header.extend(len(code).to_bytes(4, 'big'))
        
        # Comment (2048 bytes, null-padded)
        comment_bytes = self.comment.encode('utf-8')[:2047]
        header.extend(comment_bytes)
        header.extend([0] * (2048 - len(comment_bytes)))
        
        # Null separator
        header.extend([0, 0, 0, 0])
        
        return bytes(header) + code


def assemble_file(input_path: str, output_path: str = None):
    """Assemble a .s file to .cor."""
    if output_path is None:
        output_path = input_path.rsplit('.', 1)[0] + '.cor'
    
    asm = Assembler()
    
    with open(input_path, 'r') as f:
        for i, line in enumerate(f, 1):
            asm.parse_line(line, i)
    
    code = asm.compile()
    binary = asm.create_header(code)
    
    with open(output_path, 'wb') as f:
        f.write(binary)
    
    print(f"Assembled: {input_path} -> {output_path}")
    print(f"  Name: {asm.name}")
    print(f"  Code size: {len(code)} bytes")
    
    return output_path


def main():
    if len(sys.argv) < 2:
        print("Corewar Assembler")
        print()
        print("Usage:")
        print("  ./asm.py <file.s> [output.cor]")
        print()
        print("Example:")
        print("  ./asm.py warrior.s")
        return
    
    input_file = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else None
    
    assemble_file(input_file, output_file)


if __name__ == "__main__":
    main()
