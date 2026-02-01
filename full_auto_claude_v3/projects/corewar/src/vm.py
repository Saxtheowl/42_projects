#!/usr/bin/env python3
"""
Corewar Virtual Machine
A battle arena where programs (warriors) fight for memory control.
"""

from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple
from enum import Enum
import struct
import sys


class OpCode(Enum):
    LIVE = 0x01   # Declare process alive
    LD = 0x02     # Load value into register
    ST = 0x03     # Store register value
    ADD = 0x04    # Add two registers
    SUB = 0x05    # Subtract two registers
    AND = 0x06    # Bitwise AND
    OR = 0x07     # Bitwise OR
    XOR = 0x08    # Bitwise XOR
    ZJMP = 0x09   # Jump if zero
    LDI = 0x0A    # Load indexed
    STI = 0x0B    # Store indexed
    FORK = 0x0C   # Create new process
    LLD = 0x0D    # Long load
    LLDI = 0x0E   # Long load indexed
    LFORK = 0x0F  # Long fork
    AFF = 0x10    # Display character


@dataclass
class Process:
    pc: int = 0                      # Program counter
    registers: List[int] = field(default_factory=lambda: [0] * 16)
    carry: bool = False              # Carry flag
    last_live: int = 0               # Cycle of last live call
    wait_cycles: int = 0             # Cycles to wait before next op
    player_id: int = 0               # Owner player
    alive: bool = True


@dataclass
class Player:
    id: int
    name: str
    code: bytes
    last_live: int = 0
    live_count: int = 0


class VirtualMachine:
    MEM_SIZE = 4096
    CYCLE_TO_DIE = 1536
    CYCLE_DELTA = 50
    NBR_LIVE = 21
    MAX_CHECKS = 10
    
    # Instruction costs
    OP_CYCLES = {
        OpCode.LIVE: 10, OpCode.LD: 5, OpCode.ST: 5, OpCode.ADD: 10,
        OpCode.SUB: 10, OpCode.AND: 6, OpCode.OR: 6, OpCode.XOR: 6,
        OpCode.ZJMP: 20, OpCode.LDI: 25, OpCode.STI: 25, OpCode.FORK: 800,
        OpCode.LLD: 10, OpCode.LLDI: 50, OpCode.LFORK: 1000, OpCode.AFF: 2
    }
    
    def __init__(self):
        self.memory = bytearray(self.MEM_SIZE)
        self.players: List[Player] = []
        self.processes: List[Process] = []
        self.cycle = 0
        self.cycle_to_die = self.CYCLE_TO_DIE
        self.checks = 0
        self.total_lives = 0
        self.last_alive_player = 0
        self.dump_cycle = -1
        self.verbose = False
    
    def load_player(self, code: bytes, name: str = "Player"):
        """Load a player's code into memory."""
        player_id = len(self.players) + 1
        player = Player(id=player_id, name=name, code=code)
        self.players.append(player)
        
        # Calculate starting position
        start = (player_id - 1) * (self.MEM_SIZE // max(1, len(self.players) + 1))
        start = start % self.MEM_SIZE
        
        # Copy code to memory
        for i, byte in enumerate(code):
            self.memory[(start + i) % self.MEM_SIZE] = byte
        
        # Create initial process
        process = Process(pc=start, player_id=player_id)
        process.registers[0] = -player_id  # r1 contains -player_id
        self.processes.append(process)
        
        return player_id
    
    def read_mem(self, addr: int, size: int) -> int:
        """Read bytes from memory as big-endian integer."""
        addr = addr % self.MEM_SIZE
        value = 0
        for i in range(size):
            value = (value << 8) | self.memory[(addr + i) % self.MEM_SIZE]
        # Sign extend if negative
        if size == 4 and value >= 0x80000000:
            value -= 0x100000000
        elif size == 2 and value >= 0x8000:
            value -= 0x10000
        return value
    
    def write_mem(self, addr: int, value: int, size: int):
        """Write bytes to memory as big-endian."""
        addr = addr % self.MEM_SIZE
        for i in range(size - 1, -1, -1):
            self.memory[(addr + i) % self.MEM_SIZE] = value & 0xFF
            value >>= 8
    
    def get_arg(self, proc: Process, arg_type: int, size: int) -> Tuple[int, int]:
        """Get argument value and advance PC. Returns (value, bytes_read)."""
        if arg_type == 1:  # Register
            reg_num = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            if 1 <= reg_num <= 16:
                return proc.registers[reg_num - 1], 1
            return 0, 1
        elif arg_type == 2:  # Direct
            value = self.read_mem(proc.pc, size)
            proc.pc += size
            return value, size
        elif arg_type == 3:  # Indirect
            offset = self.read_mem(proc.pc, 2)
            proc.pc += 2
            return self.read_mem(proc.pc - 2 + (offset % 512), 4), 2
        return 0, 0
    
    def execute_instruction(self, proc: Process):
        """Execute one instruction for a process."""
        opcode = self.memory[proc.pc % self.MEM_SIZE]
        proc.pc += 1
        
        try:
            op = OpCode(opcode)
        except ValueError:
            return  # Invalid opcode
        
        if op == OpCode.LIVE:
            player_id = self.read_mem(proc.pc, 4)
            proc.pc += 4
            proc.last_live = self.cycle
            self.total_lives += 1
            
            # Check if valid player
            for player in self.players:
                if player.id == abs(player_id):
                    player.last_live = self.cycle
                    player.live_count += 1
                    self.last_alive_player = player.id
                    if self.verbose:
                        print(f"Player {player.id} ({player.name}) is alive!")
        
        elif op == OpCode.LD:
            encoding = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            arg_type = (encoding >> 6) & 0x3
            value, _ = self.get_arg(proc, arg_type, 4)
            reg_num = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            if 1 <= reg_num <= 16:
                proc.registers[reg_num - 1] = value
                proc.carry = (value == 0)
        
        elif op == OpCode.ST:
            encoding = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            reg_num = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            if 1 <= reg_num <= 16:
                value = proc.registers[reg_num - 1]
                dest_type = (encoding >> 4) & 0x3
                if dest_type == 1:  # Register
                    dest_reg = self.memory[proc.pc % self.MEM_SIZE]
                    proc.pc += 1
                    if 1 <= dest_reg <= 16:
                        proc.registers[dest_reg - 1] = value
                elif dest_type == 3:  # Indirect
                    offset = self.read_mem(proc.pc, 2)
                    proc.pc += 2
                    self.write_mem(proc.pc - 4 + (offset % 512), value, 4)
        
        elif op in [OpCode.ADD, OpCode.SUB]:
            encoding = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            r1 = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            r2 = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            r3 = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            if 1 <= r1 <= 16 and 1 <= r2 <= 16 and 1 <= r3 <= 16:
                if op == OpCode.ADD:
                    result = proc.registers[r1 - 1] + proc.registers[r2 - 1]
                else:
                    result = proc.registers[r1 - 1] - proc.registers[r2 - 1]
                proc.registers[r3 - 1] = result & 0xFFFFFFFF
                proc.carry = (result == 0)
        
        elif op in [OpCode.AND, OpCode.OR, OpCode.XOR]:
            encoding = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            t1 = (encoding >> 6) & 0x3
            t2 = (encoding >> 4) & 0x3
            v1, _ = self.get_arg(proc, t1, 4)
            v2, _ = self.get_arg(proc, t2, 4)
            reg = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            if 1 <= reg <= 16:
                if op == OpCode.AND:
                    result = v1 & v2
                elif op == OpCode.OR:
                    result = v1 | v2
                else:
                    result = v1 ^ v2
                proc.registers[reg - 1] = result
                proc.carry = (result == 0)
        
        elif op == OpCode.ZJMP:
            offset = self.read_mem(proc.pc, 2)
            proc.pc += 2
            if proc.carry:
                proc.pc = (proc.pc - 3 + (offset % 512)) % self.MEM_SIZE
        
        elif op == OpCode.FORK:
            offset = self.read_mem(proc.pc, 2)
            proc.pc += 2
            new_proc = Process(
                pc=(proc.pc - 3 + (offset % 512)) % self.MEM_SIZE,
                registers=proc.registers.copy(),
                carry=proc.carry,
                last_live=proc.last_live,
                player_id=proc.player_id
            )
            self.processes.append(new_proc)
        
        elif op == OpCode.AFF:
            encoding = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            reg = self.memory[proc.pc % self.MEM_SIZE]
            proc.pc += 1
            if 1 <= reg <= 16:
                char = proc.registers[reg - 1] % 256
                if self.verbose:
                    print(chr(char), end='')
    
    def run_cycle(self):
        """Run one cycle of the VM."""
        self.cycle += 1
        
        for proc in self.processes:
            if not proc.alive:
                continue
            
            if proc.wait_cycles > 0:
                proc.wait_cycles -= 1
                continue
            
            # Execute instruction
            opcode = self.memory[proc.pc % self.MEM_SIZE]
            try:
                op = OpCode(opcode)
                proc.wait_cycles = self.OP_CYCLES.get(op, 1) - 1
            except ValueError:
                proc.wait_cycles = 0
            
            self.execute_instruction(proc)
    
    def check_lives(self):
        """Check which processes are still alive."""
        # Kill processes that haven't called live
        alive_count = 0
        for proc in self.processes:
            if proc.alive:
                if self.cycle - proc.last_live >= self.cycle_to_die:
                    proc.alive = False
                else:
                    alive_count += 1
        
        # Decrease cycle_to_die if needed
        if self.total_lives >= self.NBR_LIVE:
            self.cycle_to_die -= self.CYCLE_DELTA
            self.checks = 0
        else:
            self.checks += 1
            if self.checks >= self.MAX_CHECKS:
                self.cycle_to_die -= self.CYCLE_DELTA
                self.checks = 0
        
        self.total_lives = 0
        
        return alive_count > 0
    
    def run(self, max_cycles: int = 100000):
        """Run the VM until completion."""
        last_check = 0
        
        while self.cycle < max_cycles:
            self.run_cycle()
            
            # Check every cycle_to_die cycles
            if self.cycle - last_check >= self.cycle_to_die:
                if not self.check_lives():
                    break
                last_check = self.cycle
            
            # Dump memory if requested
            if self.dump_cycle > 0 and self.cycle >= self.dump_cycle:
                self.dump_memory()
                break
        
        return self.get_winner()
    
    def get_winner(self) -> Optional[Player]:
        """Get the winning player."""
        if self.last_alive_player:
            for player in self.players:
                if player.id == self.last_alive_player:
                    return player
        return self.players[0] if self.players else None
    
    def dump_memory(self):
        """Dump memory contents."""
        for i in range(0, self.MEM_SIZE, 32):
            print(f"0x{i:04x}: ", end="")
            print(" ".join(f"{self.memory[i+j]:02x}" for j in range(32)))


def create_warrior_live():
    """Create a simple warrior that just calls LIVE."""
    # live %1
    return bytes([0x01, 0x00, 0x00, 0x00, 0x01])


def create_warrior_loop():
    """Create a warrior that loops and calls LIVE."""
    # live %1
    # zjmp %-5
    return bytes([
        0x01, 0x00, 0x00, 0x00, 0x01,  # live %1
        0x09, 0xff, 0xfb                 # zjmp %-5
    ])


def main():
    if len(sys.argv) < 2:
        print("Corewar Virtual Machine")
        print()
        print("Usage:")
        print("  ./vm.py <champion1.cor> [champion2.cor] ...")
        print("  ./vm.py --demo")
        print()
        print("Options:")
        print("  -d N    Dump memory at cycle N")
        print("  -v      Verbose mode")
        return
    
    vm = VirtualMachine()
    
    if "--demo" in sys.argv:
        # Demo with simple warriors
        print("Loading demo warriors...")
        vm.load_player(create_warrior_loop(), "Looper")
        vm.load_player(create_warrior_live(), "Once")
        vm.verbose = True
    else:
        # Load champion files
        for arg in sys.argv[1:]:
            if arg == "-v":
                vm.verbose = True
            elif arg == "-d":
                continue
            elif arg.endswith(".cor"):
                try:
                    with open(arg, 'rb') as f:
                        code = f.read()
                    name = arg.split('/')[-1].replace('.cor', '')
                    vm.load_player(code, name)
                    print(f"Loaded: {name} ({len(code)} bytes)")
                except Exception as e:
                    print(f"Error loading {arg}: {e}")
    
    print(f"\nStarting battle with {len(vm.players)} players...")
    print(f"Memory size: {vm.MEM_SIZE} bytes")
    print()
    
    winner = vm.run()
    
    print()
    print(f"Battle ended at cycle {vm.cycle}")
    if winner:
        print(f"Winner: Player {winner.id} ({winner.name})")
    else:
        print("No winner")


if __name__ == "__main__":
    main()
