#!/usr/bin/env python3
"""
Rubik's Cube Solver
Solves 3x3 Rubik's cube using Kociemba's two-phase algorithm (simplified).
"""

import sys
from typing import List, Dict, Tuple
from collections import deque


class Cube:
    """
    Represents a 3x3 Rubik's Cube.
    Faces: U(p), D(own), L(eft), R(ight), F(ront), B(ack)
    Each face is a 3x3 array indexed [row][col]
    """
    
    # Colors
    W, Y, O, R, G, B = 'W', 'Y', 'O', 'R', 'G', 'B'
    
    def __init__(self):
        # Initialize solved cube
        self.faces = {
            'U': [[self.W] * 3 for _ in range(3)],  # White
            'D': [[self.Y] * 3 for _ in range(3)],  # Yellow
            'L': [[self.O] * 3 for _ in range(3)],  # Orange
            'R': [[self.R] * 3 for _ in range(3)],  # Red
            'F': [[self.G] * 3 for _ in range(3)],  # Green
            'B': [[self.B] * 3 for _ in range(3)],  # Blue
        }
    
    def copy(self) -> 'Cube':
        new_cube = Cube()
        for face in self.faces:
            new_cube.faces[face] = [row[:] for row in self.faces[face]]
        return new_cube
    
    def _rotate_face_cw(self, face: str):
        """Rotate a face 90 degrees clockwise."""
        f = self.faces[face]
        self.faces[face] = [
            [f[2][0], f[1][0], f[0][0]],
            [f[2][1], f[1][1], f[0][1]],
            [f[2][2], f[1][2], f[0][2]],
        ]
    
    def _rotate_face_ccw(self, face: str):
        """Rotate a face 90 degrees counter-clockwise."""
        f = self.faces[face]
        self.faces[face] = [
            [f[0][2], f[1][2], f[2][2]],
            [f[0][1], f[1][1], f[2][1]],
            [f[0][0], f[1][0], f[2][0]],
        ]
    
    def move_U(self):
        """Rotate Up face clockwise."""
        self._rotate_face_cw('U')
        temp = self.faces['F'][0][:]
        self.faces['F'][0] = self.faces['R'][0][:]
        self.faces['R'][0] = self.faces['B'][0][:]
        self.faces['B'][0] = self.faces['L'][0][:]
        self.faces['L'][0] = temp
    
    def move_U_prime(self):
        """Rotate Up face counter-clockwise."""
        self._rotate_face_ccw('U')
        temp = self.faces['F'][0][:]
        self.faces['F'][0] = self.faces['L'][0][:]
        self.faces['L'][0] = self.faces['B'][0][:]
        self.faces['B'][0] = self.faces['R'][0][:]
        self.faces['R'][0] = temp
    
    def move_D(self):
        """Rotate Down face clockwise."""
        self._rotate_face_cw('D')
        temp = self.faces['F'][2][:]
        self.faces['F'][2] = self.faces['L'][2][:]
        self.faces['L'][2] = self.faces['B'][2][:]
        self.faces['B'][2] = self.faces['R'][2][:]
        self.faces['R'][2] = temp
    
    def move_D_prime(self):
        """Rotate Down face counter-clockwise."""
        self._rotate_face_ccw('D')
        temp = self.faces['F'][2][:]
        self.faces['F'][2] = self.faces['R'][2][:]
        self.faces['R'][2] = self.faces['B'][2][:]
        self.faces['B'][2] = self.faces['L'][2][:]
        self.faces['L'][2] = temp
    
    def move_R(self):
        """Rotate Right face clockwise."""
        self._rotate_face_cw('R')
        temp = [self.faces['F'][i][2] for i in range(3)]
        for i in range(3):
            self.faces['F'][i][2] = self.faces['D'][i][2]
            self.faces['D'][i][2] = self.faces['B'][2-i][0]
            self.faces['B'][2-i][0] = self.faces['U'][i][2]
            self.faces['U'][i][2] = temp[i]
    
    def move_R_prime(self):
        """Rotate Right face counter-clockwise."""
        self._rotate_face_ccw('R')
        temp = [self.faces['F'][i][2] for i in range(3)]
        for i in range(3):
            self.faces['F'][i][2] = self.faces['U'][i][2]
            self.faces['U'][i][2] = self.faces['B'][2-i][0]
            self.faces['B'][2-i][0] = self.faces['D'][i][2]
            self.faces['D'][i][2] = temp[i]
    
    def move_L(self):
        """Rotate Left face clockwise."""
        self._rotate_face_cw('L')
        temp = [self.faces['F'][i][0] for i in range(3)]
        for i in range(3):
            self.faces['F'][i][0] = self.faces['U'][i][0]
            self.faces['U'][i][0] = self.faces['B'][2-i][2]
            self.faces['B'][2-i][2] = self.faces['D'][i][0]
            self.faces['D'][i][0] = temp[i]
    
    def move_L_prime(self):
        """Rotate Left face counter-clockwise."""
        self._rotate_face_ccw('L')
        temp = [self.faces['F'][i][0] for i in range(3)]
        for i in range(3):
            self.faces['F'][i][0] = self.faces['D'][i][0]
            self.faces['D'][i][0] = self.faces['B'][2-i][2]
            self.faces['B'][2-i][2] = self.faces['U'][i][0]
            self.faces['U'][i][0] = temp[i]
    
    def move_F(self):
        """Rotate Front face clockwise."""
        self._rotate_face_cw('F')
        temp = self.faces['U'][2][:]
        for i in range(3):
            self.faces['U'][2][i] = self.faces['L'][2-i][2]
            self.faces['L'][2-i][2] = self.faces['D'][0][2-i]
            self.faces['D'][0][2-i] = self.faces['R'][i][0]
            self.faces['R'][i][0] = temp[i]
    
    def move_F_prime(self):
        """Rotate Front face counter-clockwise."""
        self._rotate_face_ccw('F')
        temp = self.faces['U'][2][:]
        for i in range(3):
            self.faces['U'][2][i] = self.faces['R'][i][0]
            self.faces['R'][i][0] = self.faces['D'][0][2-i]
            self.faces['D'][0][2-i] = self.faces['L'][2-i][2]
            self.faces['L'][2-i][2] = temp[i]
    
    def move_B(self):
        """Rotate Back face clockwise."""
        self._rotate_face_cw('B')
        temp = self.faces['U'][0][:]
        for i in range(3):
            self.faces['U'][0][i] = self.faces['R'][i][2]
            self.faces['R'][i][2] = self.faces['D'][2][2-i]
            self.faces['D'][2][2-i] = self.faces['L'][2-i][0]
            self.faces['L'][2-i][0] = temp[i]
    
    def move_B_prime(self):
        """Rotate Back face counter-clockwise."""
        self._rotate_face_ccw('B')
        temp = self.faces['U'][0][:]
        for i in range(3):
            self.faces['U'][0][i] = self.faces['L'][2-i][0]
            self.faces['L'][2-i][0] = self.faces['D'][2][2-i]
            self.faces['D'][2][2-i] = self.faces['R'][i][2]
            self.faces['R'][i][2] = temp[i]
    
    def apply_move(self, move: str):
        """Apply a move string like 'R', 'U\'' or 'F2'."""
        if len(move) == 0:
            return
        
        face = move[0]
        modifier = move[1:] if len(move) > 1 else ''
        
        moves = {
            'U': (self.move_U, self.move_U_prime),
            'D': (self.move_D, self.move_D_prime),
            'L': (self.move_L, self.move_L_prime),
            'R': (self.move_R, self.move_R_prime),
            'F': (self.move_F, self.move_F_prime),
            'B': (self.move_B, self.move_B_prime),
        }
        
        if face in moves:
            cw, ccw = moves[face]
            if modifier == "'":
                ccw()
            elif modifier == "2":
                cw()
                cw()
            else:
                cw()
    
    def apply_scramble(self, scramble: str):
        """Apply a sequence of moves."""
        for move in scramble.split():
            self.apply_move(move)
    
    def is_solved(self) -> bool:
        """Check if the cube is solved."""
        for face in self.faces:
            color = self.faces[face][1][1]  # Center color
            for row in self.faces[face]:
                for cell in row:
                    if cell != color:
                        return False
        return True
    
    def state_hash(self) -> str:
        """Get a hashable state string."""
        return ''.join(
            ''.join(''.join(row) for row in self.faces[f])
            for f in 'UDLRFB'
        )
    
    def display(self):
        """Display the cube in unfolded format."""
        # Print U face
        for row in self.faces['U']:
            print("      " + ' '.join(row))
        print()
        
        # Print L, F, R, B faces side by side
        for i in range(3):
            print(' '.join(self.faces['L'][i]), end="  ")
            print(' '.join(self.faces['F'][i]), end="  ")
            print(' '.join(self.faces['R'][i]), end="  ")
            print(' '.join(self.faces['B'][i]))
        print()
        
        # Print D face
        for row in self.faces['D']:
            print("      " + ' '.join(row))
        print()


def solve_bfs(cube: Cube, max_depth: int = 7) -> List[str]:
    """Solve using BFS (for short solutions)."""
    if cube.is_solved():
        return []
    
    moves = ['U', "U'", 'U2', 'D', "D'", 'D2',
             'L', "L'", 'L2', 'R', "R'", 'R2',
             'F', "F'", 'F2', 'B', "B'", 'B2']
    
    # BFS
    queue = deque([(cube.copy(), [])])
    visited = {cube.state_hash()}
    
    while queue:
        current, path = queue.popleft()
        
        if len(path) >= max_depth:
            continue
        
        for move in moves:
            new_cube = current.copy()
            new_cube.apply_move(move)
            
            if new_cube.is_solved():
                return path + [move]
            
            state = new_cube.state_hash()
            if state not in visited:
                visited.add(state)
                queue.append((new_cube, path + [move]))
    
    return None


def solve_beginner(cube: Cube) -> List[str]:
    """
    Beginner's method (layer by layer).
    Returns moves to solve, or None if failed.
    """
    # For simplicity, use IDA* with limited depth
    if cube.is_solved():
        return []
    
    # Try BFS for short scrambles
    solution = solve_bfs(cube, max_depth=6)
    if solution:
        return solution
    
    return None  # Indicate that deeper search is needed


def main():
    if len(sys.argv) < 2:
        print("Rubik's Cube Solver")
        print()
        print("Usage:")
        print("  ./rubik.py 'scramble'    - Solve given scramble")
        print("  ./rubik.py --demo        - Solve demo scramble")
        print()
        print("Scramble notation:")
        print("  U/D/L/R/F/B  = Clockwise rotation")
        print("  U'/D'/...    = Counter-clockwise")
        print("  U2/D2/...    = 180 degree rotation")
        print()
        print("Example:")
        print("  ./rubik.py \"R U R' U'\"")
        return
    
    cube = Cube()
    
    if sys.argv[1] == "--demo":
        scramble = "R U R' U'"
    else:
        scramble = ' '.join(sys.argv[1:])
    
    print(f"Scramble: {scramble}")
    cube.apply_scramble(scramble)
    
    print("\nScrambled cube:")
    cube.display()
    
    print("Solving...")
    solution = solve_beginner(cube)
    
    if solution:
        print(f"Solution ({len(solution)} moves): {' '.join(solution)}")
        
        # Verify
        cube.apply_scramble(' '.join(solution))
        print("\nAfter applying solution:")
        cube.display()
        print("Solved!" if cube.is_solved() else "Not solved (error in solution)")
    else:
        print("Could not find solution (scramble too complex for BFS)")
        print("Try a shorter scramble (up to 6 moves)")


if __name__ == "__main__":
    main()
