#!/usr/bin/env python3
"""
Gomoku - Five in a row game with AI
"""

import sys
from typing import List, Optional, Tuple

SIZE = 15
EMPTY = '.'
BLACK = 'X'  # Player
WHITE = 'O'  # AI


class Board:
    def __init__(self, size: int = SIZE):
        self.size = size
        self.grid: List[List[str]] = [[EMPTY] * size for _ in range(size)]
        self.last_move: Optional[Tuple[int, int]] = None
    
    def display(self):
        """Display the board."""
        # Column numbers
        print("   ", end="")
        for c in range(self.size):
            print(f"{c:2d}", end="")
        print()
        
        for r in range(self.size):
            print(f"{r:2d} ", end="")
            for c in range(self.size):
                if self.last_move == (r, c):
                    print(f"[{self.grid[r][c]}]"[1:3], end="")
                else:
                    print(f" {self.grid[r][c]}", end="")
            print()
        print()
    
    def is_valid(self, row: int, col: int) -> bool:
        return (0 <= row < self.size and 0 <= col < self.size and 
                self.grid[row][col] == EMPTY)
    
    def place(self, row: int, col: int, piece: str) -> bool:
        if not self.is_valid(row, col):
            return False
        self.grid[row][col] = piece
        self.last_move = (row, col)
        return True
    
    def remove(self, row: int, col: int):
        self.grid[row][col] = EMPTY
    
    def check_winner(self) -> Optional[str]:
        """Check for five in a row."""
        directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for r in range(self.size):
            for c in range(self.size):
                if self.grid[r][c] == EMPTY:
                    continue
                piece = self.grid[r][c]
                
                for dr, dc in directions:
                    count = 0
                    nr, nc = r, c
                    while (0 <= nr < self.size and 0 <= nc < self.size and 
                           self.grid[nr][nc] == piece):
                        count += 1
                        nr += dr
                        nc += dc
                    
                    if count >= 5:
                        return piece
        
        return None
    
    def is_full(self) -> bool:
        for row in self.grid:
            if EMPTY in row:
                return False
        return True
    
    def get_empty_cells(self) -> List[Tuple[int, int]]:
        """Get all empty cells, prioritizing cells near existing pieces."""
        candidates = set()
        
        # Add cells adjacent to existing pieces
        for r in range(self.size):
            for c in range(self.size):
                if self.grid[r][c] != EMPTY:
                    for dr in range(-2, 3):
                        for dc in range(-2, 3):
                            nr, nc = r + dr, c + dc
                            if (0 <= nr < self.size and 0 <= nc < self.size and 
                                self.grid[nr][nc] == EMPTY):
                                candidates.add((nr, nc))
        
        # If no pieces on board, return center area
        if not candidates:
            center = self.size // 2
            for dr in range(-2, 3):
                for dc in range(-2, 3):
                    nr, nc = center + dr, center + dc
                    if 0 <= nr < self.size and 0 <= nc < self.size:
                        candidates.add((nr, nc))
        
        return list(candidates)
    
    def evaluate_line(self, r: int, c: int, dr: int, dc: int, piece: str) -> int:
        """Evaluate a line starting at (r, c) in direction (dr, dc)."""
        opponent = WHITE if piece == BLACK else BLACK
        score = 0
        
        # Count pieces in both directions
        count = 0
        open_ends = 0
        
        # Forward direction
        nr, nc = r, c
        while (0 <= nr < self.size and 0 <= nc < self.size and 
               self.grid[nr][nc] == piece):
            count += 1
            nr += dr
            nc += dc
        
        if 0 <= nr < self.size and 0 <= nc < self.size and self.grid[nr][nc] == EMPTY:
            open_ends += 1
        
        # Backward direction
        nr, nc = r - dr, c - dc
        while (0 <= nr < self.size and 0 <= nc < self.size and 
               self.grid[nr][nc] == piece):
            count += 1
            nr -= dr
            nc -= dc
        
        if 0 <= nr < self.size and 0 <= nc < self.size and self.grid[nr][nc] == EMPTY:
            open_ends += 1
        
        # Score based on count and openness
        if count >= 5:
            return 100000
        if count == 4:
            if open_ends == 2:
                return 10000
            if open_ends == 1:
                return 1000
        if count == 3:
            if open_ends == 2:
                return 1000
            if open_ends == 1:
                return 100
        if count == 2:
            if open_ends == 2:
                return 100
            if open_ends == 1:
                return 10
        
        return count * open_ends
    
    def evaluate(self, piece: str) -> int:
        """Evaluate board position for the given piece."""
        opponent = WHITE if piece == BLACK else BLACK
        score = 0
        directions = [(0, 1), (1, 0), (1, 1), (1, -1)]
        
        for r in range(self.size):
            for c in range(self.size):
                if self.grid[r][c] == piece:
                    for dr, dc in directions:
                        score += self.evaluate_line(r, c, dr, dc, piece)
                elif self.grid[r][c] == opponent:
                    for dr, dc in directions:
                        score -= self.evaluate_line(r, c, dr, dc, opponent) * 1.1
        
        return int(score)


def minimax(board: Board, depth: int, alpha: float, beta: float, 
            maximizing: bool, ai_piece: str) -> Tuple[int, Optional[Tuple[int, int]]]:
    """Minimax with alpha-beta pruning."""
    winner = board.check_winner()
    if winner == ai_piece:
        return 1000000 + depth, None
    if winner:
        return -1000000 - depth, None
    if depth == 0 or board.is_full():
        return board.evaluate(ai_piece), None
    
    empty_cells = board.get_empty_cells()
    if not empty_cells:
        return 0, None
    
    # Sort moves by potential (heuristic)
    def move_priority(pos):
        r, c = pos
        board.place(r, c, ai_piece if maximizing else (BLACK if ai_piece == WHITE else WHITE))
        score = board.evaluate(ai_piece)
        board.remove(r, c)
        return -score if maximizing else score
    
    empty_cells.sort(key=move_priority)
    empty_cells = empty_cells[:15]  # Limit branching factor
    
    if maximizing:
        max_eval = float('-inf')
        best_move = empty_cells[0]
        for r, c in empty_cells:
            board.place(r, c, ai_piece)
            eval_score, _ = minimax(board, depth - 1, alpha, beta, False, ai_piece)
            board.remove(r, c)
            if eval_score > max_eval:
                max_eval = eval_score
                best_move = (r, c)
            alpha = max(alpha, eval_score)
            if beta <= alpha:
                break
        return max_eval, best_move
    else:
        min_eval = float('inf')
        best_move = empty_cells[0]
        player_piece = BLACK if ai_piece == WHITE else WHITE
        for r, c in empty_cells:
            board.place(r, c, player_piece)
            eval_score, _ = minimax(board, depth - 1, alpha, beta, True, ai_piece)
            board.remove(r, c)
            if eval_score < min_eval:
                min_eval = eval_score
                best_move = (r, c)
            beta = min(beta, eval_score)
            if beta <= alpha:
                break
        return min_eval, best_move


def get_ai_move(board: Board, depth: int = 3) -> Tuple[int, int]:
    """Get the best move for AI."""
    _, move = minimax(board, depth, float('-inf'), float('inf'), True, WHITE)
    return move if move else (board.size // 2, board.size // 2)


def play_game():
    """Main game loop."""
    board = Board()
    current = BLACK
    
    print("Gomoku - Five in a Row!")
    print(f"You are {BLACK}, AI is {WHITE}")
    print("Enter row and column (e.g., '7 7')")
    
    while True:
        board.display()
        
        winner = board.check_winner()
        if winner:
            print(f"{'You win!' if winner == BLACK else 'AI wins!'}")
            break
        
        if board.is_full():
            print("It's a draw!")
            break
        
        if current == BLACK:
            while True:
                try:
                    move = input(f"Your move ({BLACK}): ").strip().split()
                    if len(move) == 2:
                        row, col = int(move[0]), int(move[1])
                        if board.place(row, col, BLACK):
                            break
                    print("Invalid move. Try again.")
                except ValueError:
                    print("Enter row and column (e.g., '7 7')")
                except EOFError:
                    print("\nGame ended.")
                    return
            current = WHITE
        else:
            print("AI is thinking...")
            row, col = get_ai_move(board)
            board.place(row, col, WHITE)
            print(f"AI plays: {row} {col}")
            current = BLACK
    
    board.display()


def main():
    play_game()


if __name__ == "__main__":
    main()
