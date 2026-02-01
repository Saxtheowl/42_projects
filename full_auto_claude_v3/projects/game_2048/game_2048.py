#!/usr/bin/env python3
"""
2048 - Sliding tile puzzle game
"""

import random
import sys
from typing import List, Tuple, Optional


class Game2048:
    def __init__(self, size: int = 4):
        self.size = size
        self.grid: List[List[int]] = [[0] * size for _ in range(size)]
        self.score = 0
        self.add_random_tile()
        self.add_random_tile()
    
    def add_random_tile(self) -> bool:
        """Add a 2 or 4 to a random empty cell. Returns False if no empty cell."""
        empty_cells = [(r, c) for r in range(self.size) 
                       for c in range(self.size) if self.grid[r][c] == 0]
        if not empty_cells:
            return False
        r, c = random.choice(empty_cells)
        self.grid[r][c] = 4 if random.random() < 0.1 else 2
        return True
    
    def display(self):
        """Display the game board."""
        width = 6
        line = '+' + (('-' * width + '+') * self.size)
        
        print(f"\nScore: {self.score}")
        print(line)
        for row in self.grid:
            cells = ['|' + (str(c) if c else '.').center(width) for c in row]
            print(''.join(cells) + '|')
            print(line)
        print()
    
    def slide_row_left(self, row: List[int]) -> Tuple[List[int], int]:
        """Slide a row to the left and merge. Returns new row and points gained."""
        # Remove zeros
        new_row = [x for x in row if x != 0]
        points = 0
        
        # Merge adjacent equal tiles
        merged = []
        i = 0
        while i < len(new_row):
            if i + 1 < len(new_row) and new_row[i] == new_row[i + 1]:
                merged_val = new_row[i] * 2
                merged.append(merged_val)
                points += merged_val
                i += 2
            else:
                merged.append(new_row[i])
                i += 1
        
        # Pad with zeros
        while len(merged) < self.size:
            merged.append(0)
        
        return merged, points
    
    def move_left(self) -> bool:
        """Move all tiles left. Returns True if any tile moved."""
        moved = False
        for r in range(self.size):
            new_row, points = self.slide_row_left(self.grid[r])
            if new_row != self.grid[r]:
                moved = True
            self.grid[r] = new_row
            self.score += points
        return moved
    
    def move_right(self) -> bool:
        """Move all tiles right."""
        moved = False
        for r in range(self.size):
            reversed_row = self.grid[r][::-1]
            new_row, points = self.slide_row_left(reversed_row)
            new_row = new_row[::-1]
            if new_row != self.grid[r]:
                moved = True
            self.grid[r] = new_row
            self.score += points
        return moved
    
    def move_up(self) -> bool:
        """Move all tiles up."""
        moved = False
        for c in range(self.size):
            col = [self.grid[r][c] for r in range(self.size)]
            new_col, points = self.slide_row_left(col)
            if new_col != col:
                moved = True
            for r in range(self.size):
                self.grid[r][c] = new_col[r]
            self.score += points
        return moved
    
    def move_down(self) -> bool:
        """Move all tiles down."""
        moved = False
        for c in range(self.size):
            col = [self.grid[r][c] for r in range(self.size)]
            reversed_col = col[::-1]
            new_col, points = self.slide_row_left(reversed_col)
            new_col = new_col[::-1]
            if new_col != col:
                moved = True
            for r in range(self.size):
                self.grid[r][c] = new_col[r]
            self.score += points
        return moved
    
    def move(self, direction: str) -> bool:
        """Make a move in the given direction. Returns True if moved."""
        if direction in ('w', 'up'):
            return self.move_up()
        elif direction in ('s', 'down'):
            return self.move_down()
        elif direction in ('a', 'left'):
            return self.move_left()
        elif direction in ('d', 'right'):
            return self.move_right()
        return False
    
    def has_won(self) -> bool:
        """Check if player has reached 2048."""
        for row in self.grid:
            if 2048 in row:
                return True
        return False
    
    def can_move(self) -> bool:
        """Check if any move is possible."""
        # Check for empty cells
        for row in self.grid:
            if 0 in row:
                return True
        
        # Check for adjacent equal tiles
        for r in range(self.size):
            for c in range(self.size):
                val = self.grid[r][c]
                if c + 1 < self.size and self.grid[r][c + 1] == val:
                    return True
                if r + 1 < self.size and self.grid[r + 1][c] == val:
                    return True
        
        return False
    
    def is_game_over(self) -> bool:
        """Check if game is over."""
        return not self.can_move()


def get_best_move(game: Game2048) -> str:
    """Simple AI to find best move using look-ahead."""
    moves = ['up', 'left', 'down', 'right']
    best_score = -1
    best_move = 'up'
    
    for move in moves:
        # Copy game state
        test_game = Game2048(game.size)
        test_game.grid = [row[:] for row in game.grid]
        test_game.score = game.score
        
        # Try move
        if test_game.move(move):
            if test_game.score > best_score:
                best_score = test_game.score
                best_move = move
    
    return best_move


def play_game(auto: bool = False):
    """Main game loop."""
    game = Game2048()
    
    print("2048 Game!")
    print("Controls: w=up, s=down, a=left, d=right, q=quit")
    if auto:
        print("Auto-play mode enabled")
    
    while True:
        game.display()
        
        if game.has_won():
            print("Congratulations! You reached 2048!")
            break
        
        if game.is_game_over():
            print(f"Game Over! Final Score: {game.score}")
            break
        
        if auto:
            direction = get_best_move(game)
            print(f"AI plays: {direction}")
        else:
            try:
                direction = input("Move (wasd): ").strip().lower()
            except EOFError:
                print("\nGame ended.")
                break
            
            if direction == 'q':
                print(f"Final Score: {game.score}")
                break
        
        if game.move(direction):
            game.add_random_tile()


def main():
    auto = '--auto' in sys.argv
    play_game(auto)


if __name__ == "__main__":
    main()
