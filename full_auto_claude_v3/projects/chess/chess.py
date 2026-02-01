#!/usr/bin/env python3
"""
Chess Engine with AI opponent using Minimax with Alpha-Beta pruning.
"""

import sys
from typing import List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
import copy


class Piece(Enum):
    EMPTY = 0
    PAWN = 1
    KNIGHT = 2
    BISHOP = 3
    ROOK = 4
    QUEEN = 5
    KING = 6


class Color(Enum):
    WHITE = 0
    BLACK = 1


PIECE_SYMBOLS = {
    (Piece.PAWN, Color.WHITE): '♙', (Piece.PAWN, Color.BLACK): '♟',
    (Piece.KNIGHT, Color.WHITE): '♘', (Piece.KNIGHT, Color.BLACK): '♞',
    (Piece.BISHOP, Color.WHITE): '♗', (Piece.BISHOP, Color.BLACK): '♝',
    (Piece.ROOK, Color.WHITE): '♖', (Piece.ROOK, Color.BLACK): '♜',
    (Piece.QUEEN, Color.WHITE): '♕', (Piece.QUEEN, Color.BLACK): '♛',
    (Piece.KING, Color.WHITE): '♔', (Piece.KING, Color.BLACK): '♚',
}

PIECE_VALUES = {
    Piece.PAWN: 100, Piece.KNIGHT: 320, Piece.BISHOP: 330,
    Piece.ROOK: 500, Piece.QUEEN: 900, Piece.KING: 20000
}


@dataclass
class Square:
    piece: Piece = Piece.EMPTY
    color: Optional[Color] = None


class Board:
    def __init__(self):
        self.squares = [[Square() for _ in range(8)] for _ in range(8)]
        self.turn = Color.WHITE
        self.castling = {'K': True, 'Q': True, 'k': True, 'q': True}
        self.en_passant: Optional[Tuple[int, int]] = None
        self.halfmove = 0
        self.fullmove = 1
        self.setup_initial()
    
    def setup_initial(self):
        """Set up initial chess position."""
        # Pawns
        for c in range(8):
            self.squares[1][c] = Square(Piece.PAWN, Color.BLACK)
            self.squares[6][c] = Square(Piece.PAWN, Color.WHITE)
        
        # Back ranks
        back_rank = [Piece.ROOK, Piece.KNIGHT, Piece.BISHOP, Piece.QUEEN,
                     Piece.KING, Piece.BISHOP, Piece.KNIGHT, Piece.ROOK]
        for c, piece in enumerate(back_rank):
            self.squares[0][c] = Square(piece, Color.BLACK)
            self.squares[7][c] = Square(piece, Color.WHITE)
    
    def copy(self) -> 'Board':
        new_board = Board()
        for r in range(8):
            for c in range(8):
                new_board.squares[r][c] = Square(
                    self.squares[r][c].piece,
                    self.squares[r][c].color
                )
        new_board.turn = self.turn
        new_board.castling = self.castling.copy()
        new_board.en_passant = self.en_passant
        return new_board
    
    def display(self):
        """Display the board."""
        print("  a b c d e f g h")
        print("  ─────────────────")
        for r in range(8):
            print(f"{8-r}│", end="")
            for c in range(8):
                sq = self.squares[r][c]
                if sq.piece == Piece.EMPTY:
                    symbol = '·'
                else:
                    symbol = PIECE_SYMBOLS.get((sq.piece, sq.color), '?')
                print(f"{symbol} ", end="")
            print(f"│{8-r}")
        print("  ─────────────────")
        print("  a b c d e f g h")
        print(f"\n{'White' if self.turn == Color.WHITE else 'Black'} to move")
    
    def get_piece(self, row: int, col: int) -> Square:
        if 0 <= row < 8 and 0 <= col < 8:
            return self.squares[row][col]
        return Square()
    
    def is_valid_pos(self, row: int, col: int) -> bool:
        return 0 <= row < 8 and 0 <= col < 8
    
    def get_moves(self, row: int, col: int) -> List[Tuple[int, int, int, int]]:
        """Get all possible moves for a piece at (row, col)."""
        sq = self.squares[row][col]
        if sq.piece == Piece.EMPTY or sq.color != self.turn:
            return []
        
        moves = []
        
        if sq.piece == Piece.PAWN:
            moves.extend(self._pawn_moves(row, col, sq.color))
        elif sq.piece == Piece.KNIGHT:
            moves.extend(self._knight_moves(row, col, sq.color))
        elif sq.piece == Piece.BISHOP:
            moves.extend(self._sliding_moves(row, col, sq.color, [(-1,-1),(-1,1),(1,-1),(1,1)]))
        elif sq.piece == Piece.ROOK:
            moves.extend(self._sliding_moves(row, col, sq.color, [(-1,0),(1,0),(0,-1),(0,1)]))
        elif sq.piece == Piece.QUEEN:
            moves.extend(self._sliding_moves(row, col, sq.color, [(-1,-1),(-1,1),(1,-1),(1,1),(-1,0),(1,0),(0,-1),(0,1)]))
        elif sq.piece == Piece.KING:
            moves.extend(self._king_moves(row, col, sq.color))
        
        return moves
    
    def _pawn_moves(self, row: int, col: int, color: Color) -> List[Tuple[int, int, int, int]]:
        moves = []
        direction = -1 if color == Color.WHITE else 1
        start_row = 6 if color == Color.WHITE else 1
        
        # Forward move
        if self.is_valid_pos(row + direction, col) and self.squares[row + direction][col].piece == Piece.EMPTY:
            moves.append((row, col, row + direction, col))
            # Double move from start
            if row == start_row and self.squares[row + 2*direction][col].piece == Piece.EMPTY:
                moves.append((row, col, row + 2*direction, col))
        
        # Captures
        for dc in [-1, 1]:
            nr, nc = row + direction, col + dc
            if self.is_valid_pos(nr, nc):
                target = self.squares[nr][nc]
                if target.piece != Piece.EMPTY and target.color != color:
                    moves.append((row, col, nr, nc))
                # En passant
                if self.en_passant == (nr, nc):
                    moves.append((row, col, nr, nc))
        
        return moves
    
    def _knight_moves(self, row: int, col: int, color: Color) -> List[Tuple[int, int, int, int]]:
        moves = []
        offsets = [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)]
        for dr, dc in offsets:
            nr, nc = row + dr, col + dc
            if self.is_valid_pos(nr, nc):
                target = self.squares[nr][nc]
                if target.piece == Piece.EMPTY or target.color != color:
                    moves.append((row, col, nr, nc))
        return moves
    
    def _sliding_moves(self, row: int, col: int, color: Color, directions: List[Tuple[int, int]]) -> List[Tuple[int, int, int, int]]:
        moves = []
        for dr, dc in directions:
            nr, nc = row + dr, col + dc
            while self.is_valid_pos(nr, nc):
                target = self.squares[nr][nc]
                if target.piece == Piece.EMPTY:
                    moves.append((row, col, nr, nc))
                elif target.color != color:
                    moves.append((row, col, nr, nc))
                    break
                else:
                    break
                nr, nc = nr + dr, nc + dc
        return moves
    
    def _king_moves(self, row: int, col: int, color: Color) -> List[Tuple[int, int, int, int]]:
        moves = []
        for dr in [-1, 0, 1]:
            for dc in [-1, 0, 1]:
                if dr == 0 and dc == 0:
                    continue
                nr, nc = row + dr, col + dc
                if self.is_valid_pos(nr, nc):
                    target = self.squares[nr][nc]
                    if target.piece == Piece.EMPTY or target.color != color:
                        moves.append((row, col, nr, nc))
        return moves
    
    def get_all_moves(self, color: Color) -> List[Tuple[int, int, int, int]]:
        """Get all possible moves for a color."""
        moves = []
        for r in range(8):
            for c in range(8):
                if self.squares[r][c].color == color:
                    moves.extend(self.get_moves(r, c))
        return moves
    
    def make_move(self, fr: int, fc: int, tr: int, tc: int) -> bool:
        """Make a move. Returns True if successful."""
        piece = self.squares[fr][fc]
        if piece.piece == Piece.EMPTY or piece.color != self.turn:
            return False
        
        # Make move
        self.squares[tr][tc] = self.squares[fr][fc]
        self.squares[fr][fc] = Square()
        
        # Pawn promotion
        if piece.piece == Piece.PAWN:
            if (piece.color == Color.WHITE and tr == 0) or (piece.color == Color.BLACK and tr == 7):
                self.squares[tr][tc] = Square(Piece.QUEEN, piece.color)
        
        # Switch turn
        self.turn = Color.BLACK if self.turn == Color.WHITE else Color.WHITE
        return True
    
    def evaluate(self) -> int:
        """Evaluate board position (positive = white advantage)."""
        score = 0
        for r in range(8):
            for c in range(8):
                sq = self.squares[r][c]
                if sq.piece != Piece.EMPTY:
                    value = PIECE_VALUES[sq.piece]
                    # Position bonus
                    if sq.piece == Piece.PAWN:
                        value += (6 - r if sq.color == Color.WHITE else r - 1) * 10
                    if sq.color == Color.WHITE:
                        score += value
                    else:
                        score -= value
        return score
    
    def find_king(self, color: Color) -> Optional[Tuple[int, int]]:
        for r in range(8):
            for c in range(8):
                if self.squares[r][c].piece == Piece.KING and self.squares[r][c].color == color:
                    return (r, c)
        return None


def minimax(board: Board, depth: int, alpha: float, beta: float, maximizing: bool) -> Tuple[int, Optional[Tuple[int, int, int, int]]]:
    """Minimax with alpha-beta pruning."""
    if depth == 0:
        return board.evaluate(), None
    
    color = Color.WHITE if maximizing else Color.BLACK
    moves = board.get_all_moves(color)
    
    if not moves:
        return board.evaluate(), None
    
    best_move = moves[0]
    
    if maximizing:
        max_eval = float('-inf')
        for move in moves:
            new_board = board.copy()
            new_board.make_move(*move)
            eval_score, _ = minimax(new_board, depth - 1, alpha, beta, False)
            if eval_score > max_eval:
                max_eval = eval_score
                best_move = move
            alpha = max(alpha, eval_score)
            if beta <= alpha:
                break
        return max_eval, best_move
    else:
        min_eval = float('inf')
        for move in moves:
            new_board = board.copy()
            new_board.make_move(*move)
            eval_score, _ = minimax(new_board, depth - 1, alpha, beta, True)
            if eval_score < min_eval:
                min_eval = eval_score
                best_move = move
            beta = min(beta, eval_score)
            if beta <= alpha:
                break
        return min_eval, best_move


def get_ai_move(board: Board, depth: int = 3) -> Tuple[int, int, int, int]:
    """Get best AI move."""
    maximizing = board.turn == Color.WHITE
    _, move = minimax(board, depth, float('-inf'), float('inf'), maximizing)
    return move


def parse_move(move_str: str) -> Optional[Tuple[int, int, int, int]]:
    """Parse move like 'e2e4' to coordinates."""
    if len(move_str) != 4:
        return None
    try:
        fc = ord(move_str[0]) - ord('a')
        fr = 8 - int(move_str[1])
        tc = ord(move_str[2]) - ord('a')
        tr = 8 - int(move_str[3])
        if all(0 <= x < 8 for x in [fr, fc, tr, tc]):
            return (fr, fc, tr, tc)
    except:
        pass
    return None


def main():
    board = Board()
    ai_color = Color.BLACK
    
    print("Chess Engine")
    print("Enter moves like 'e2e4', 'quit' to exit")
    print()
    
    while True:
        board.display()
        
        if board.turn == ai_color:
            print("\nAI is thinking...")
            move = get_ai_move(board, depth=3)
            if move:
                fr, fc, tr, tc = move
                move_str = f"{chr(ord('a')+fc)}{8-fr}{chr(ord('a')+tc)}{8-tr}"
                print(f"AI plays: {move_str}")
                board.make_move(*move)
            else:
                print("AI has no moves!")
                break
        else:
            try:
                move_str = input("\nYour move: ").strip().lower()
            except EOFError:
                break
            
            if move_str == 'quit':
                break
            
            move = parse_move(move_str)
            if move and move in board.get_all_moves(board.turn):
                board.make_move(*move)
            else:
                print("Invalid move!")


if __name__ == "__main__":
    main()
