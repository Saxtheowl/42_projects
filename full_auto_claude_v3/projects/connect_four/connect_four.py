#!/usr/bin/env python3
"""
Connect Four - Two player game with AI
"""

import sys
from typing import List, Optional, Tuple

ROWS = 6
COLS = 7
EMPTY = '.'
PLAYER = 'X'
AI = 'O'


class Board:
    def __init__(self):
        self.grid: List[List[str]] = [[EMPTY] * COLS for _ in range(ROWS)]
    
    def copy(self) -> 'Board':
        new_board = Board()
        for r in range(ROWS):
            for c in range(COLS):
                new_board.grid[r][c] = self.grid[r][c]
        return new_board
    
    def display(self):
        print("\n  " + " ".join(str(i) for i in range(COLS)))
        print("  " + "-" * (COLS * 2 - 1))
        for row in self.grid:
            print("| " + " ".join(row) + " |")
        print("  " + "-" * (COLS * 2 - 1))
        print()
    
    def drop(self, col: int, piece: str) -> bool:
        """Drop a piece in the specified column. Returns True if successful."""
        if col < 0 or col >= COLS:
            return False
        for row in range(ROWS - 1, -1, -1):
            if self.grid[row][col] == EMPTY:
                self.grid[row][col] = piece
                return True
        return False
    
    def undo_drop(self, col: int):
        """Remove the top piece from a column."""
        for row in range(ROWS):
            if self.grid[row][col] != EMPTY:
                self.grid[row][col] = EMPTY
                return
    
    def is_valid_move(self, col: int) -> bool:
        return 0 <= col < COLS and self.grid[0][col] == EMPTY
    
    def get_valid_moves(self) -> List[int]:
        return [c for c in range(COLS) if self.is_valid_move(c)]
    
    def check_winner(self) -> Optional[str]:
        """Check for a winner. Returns winning piece or None."""
        # Check horizontal
        for r in range(ROWS):
            for c in range(COLS - 3):
                if (self.grid[r][c] != EMPTY and
                    self.grid[r][c] == self.grid[r][c+1] == 
                    self.grid[r][c+2] == self.grid[r][c+3]):
                    return self.grid[r][c]
        
        # Check vertical
        for r in range(ROWS - 3):
            for c in range(COLS):
                if (self.grid[r][c] != EMPTY and
                    self.grid[r][c] == self.grid[r+1][c] == 
                    self.grid[r+2][c] == self.grid[r+3][c]):
                    return self.grid[r][c]
        
        # Check diagonal (down-right)
        for r in range(ROWS - 3):
            for c in range(COLS - 3):
                if (self.grid[r][c] != EMPTY and
                    self.grid[r][c] == self.grid[r+1][c+1] == 
                    self.grid[r+2][c+2] == self.grid[r+3][c+3]):
                    return self.grid[r][c]
        
        # Check diagonal (up-right)
        for r in range(3, ROWS):
            for c in range(COLS - 3):
                if (self.grid[r][c] != EMPTY and
                    self.grid[r][c] == self.grid[r-1][c+1] == 
                    self.grid[r-2][c+2] == self.grid[r-3][c+3]):
                    return self.grid[r][c]
        
        return None
    
    def is_full(self) -> bool:
        return all(self.grid[0][c] != EMPTY for c in range(COLS))
    
    def evaluate(self, piece: str) -> int:
        """Evaluate board position for the given piece."""
        opponent = AI if piece == PLAYER else PLAYER
        score = 0
        
        # Count potential wins
        def count_window(window: List[str]) -> int:
            piece_count = window.count(piece)
            empty_count = window.count(EMPTY)
            opp_count = window.count(opponent)
            
            if piece_count == 4:
                return 1000
            if opp_count == 4:
                return -1000
            if piece_count == 3 and empty_count == 1:
                return 50
            if opp_count == 3 and empty_count == 1:
                return -50
            if piece_count == 2 and empty_count == 2:
                return 10
            if opp_count == 2 and empty_count == 2:
                return -10
            return 0
        
        # Check all windows
        for r in range(ROWS):
            for c in range(COLS - 3):
                window = [self.grid[r][c+i] for i in range(4)]
                score += count_window(window)
        
        for r in range(ROWS - 3):
            for c in range(COLS):
                window = [self.grid[r+i][c] for i in range(4)]
                score += count_window(window)
        
        for r in range(ROWS - 3):
            for c in range(COLS - 3):
                window = [self.grid[r+i][c+i] for i in range(4)]
                score += count_window(window)
        
        for r in range(3, ROWS):
            for c in range(COLS - 3):
                window = [self.grid[r-i][c+i] for i in range(4)]
                score += count_window(window)
        
        # Prefer center column
        center_count = sum(1 for r in range(ROWS) if self.grid[r][COLS//2] == piece)
        score += center_count * 3
        
        return score


def minimax(board: Board, depth: int, alpha: float, beta: float, 
            maximizing: bool) -> Tuple[int, Optional[int]]:
    """Minimax with alpha-beta pruning."""
    winner = board.check_winner()
    if winner == AI:
        return 10000 + depth, None
    if winner == PLAYER:
        return -10000 - depth, None
    if board.is_full() or depth == 0:
        return board.evaluate(AI), None
    
    valid_moves = board.get_valid_moves()
    if not valid_moves:
        return 0, None
    
    if maximizing:
        max_eval = float('-inf')
        best_col = valid_moves[0]
        for col in valid_moves:
            board.drop(col, AI)
            eval_score, _ = minimax(board, depth - 1, alpha, beta, False)
            board.undo_drop(col)
            if eval_score > max_eval:
                max_eval = eval_score
                best_col = col
            alpha = max(alpha, eval_score)
            if beta <= alpha:
                break
        return max_eval, best_col
    else:
        min_eval = float('inf')
        best_col = valid_moves[0]
        for col in valid_moves:
            board.drop(col, PLAYER)
            eval_score, _ = minimax(board, depth - 1, alpha, beta, True)
            board.undo_drop(col)
            if eval_score < min_eval:
                min_eval = eval_score
                best_col = col
            beta = min(beta, eval_score)
            if beta <= alpha:
                break
        return min_eval, best_col


def get_ai_move(board: Board, depth: int = 5) -> int:
    """Get the best move for AI using minimax."""
    _, col = minimax(board, depth, float('-inf'), float('inf'), True)
    return col if col is not None else board.get_valid_moves()[0]


def play_game():
    """Main game loop."""
    board = Board()
    current = PLAYER
    
    print("Connect Four!")
    print(f"You are {PLAYER}, AI is {AI}")
    print("Enter column number (0-6) to drop a piece")
    
    while True:
        board.display()
        
        winner = board.check_winner()
        if winner:
            if winner == PLAYER:
                print("Congratulations! You win!")
            else:
                print("AI wins! Better luck next time.")
            break
        
        if board.is_full():
            print("It's a draw!")
            break
        
        if current == PLAYER:
            while True:
                try:
                    col = int(input(f"Your move ({PLAYER}): "))
                    if board.is_valid_move(col):
                        board.drop(col, PLAYER)
                        break
                    else:
                        print("Invalid move. Try again.")
                except ValueError:
                    print("Please enter a number 0-6.")
                except EOFError:
                    print("\nGame ended.")
                    return
            current = AI
        else:
            print("AI is thinking...")
            col = get_ai_move(board)
            board.drop(col, AI)
            print(f"AI plays column {col}")
            current = PLAYER
    
    board.display()


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "--test":
        # Run a quick test
        board = Board()
        moves = [3, 3, 4, 4, 5, 5, 6]  # Player wins
        for i, col in enumerate(moves):
            piece = PLAYER if i % 2 == 0 else AI
            board.drop(col, piece)
            board.display()
            winner = board.check_winner()
            if winner:
                print(f"{winner} wins!")
                break
    else:
        play_game()


if __name__ == "__main__":
    main()
