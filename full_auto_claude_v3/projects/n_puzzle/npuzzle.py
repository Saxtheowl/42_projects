#!/usr/bin/env python3
"""
N-Puzzle Solver using A* algorithm
Solves sliding puzzle problems of any size
"""

import sys
import heapq
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass, field


@dataclass(order=True)
class State:
    priority: int
    puzzle: Tuple[int, ...] = field(compare=False)
    g_cost: int = field(compare=False)
    parent: Optional['State'] = field(compare=False, default=None)
    move: str = field(compare=False, default="")


class NPuzzle:
    def __init__(self, initial: List[List[int]], heuristic: str = "manhattan"):
        self.size = len(initial)
        self.initial = tuple(cell for row in initial for cell in row)
        self.goal = self._generate_goal()
        self.goal_positions = {val: i for i, val in enumerate(self.goal)}
        self.heuristic_name = heuristic

        if not self._is_solvable():
            raise ValueError("This puzzle is not solvable")

    def _generate_goal(self) -> Tuple[int, ...]:
        """Generate the goal state (snail/spiral pattern)"""
        n = self.size
        goal = [[0] * n for _ in range(n)]
        directions = [(0, 1), (1, 0), (0, -1), (-1, 0)]
        x, y, d = 0, 0, 0
        for num in range(1, n * n):
            goal[x][y] = num
            nx, ny = x + directions[d][0], y + directions[d][1]
            if not (0 <= nx < n and 0 <= ny < n and goal[nx][ny] == 0):
                d = (d + 1) % 4
                nx, ny = x + directions[d][0], y + directions[d][1]
            x, y = nx, ny
        goal[x][y] = 0  # Empty cell (0) at the end
        return tuple(cell for row in goal for cell in row)

    def _count_inversions(self, puzzle: Tuple[int, ...]) -> int:
        """Count inversions for solvability check"""
        inversions = 0
        puzzle_list = [x for x in puzzle if x != 0]
        goal_list = [x for x in self.goal if x != 0]
        goal_positions = {val: i for i, val in enumerate(goal_list)}

        for i in range(len(puzzle_list)):
            for j in range(i + 1, len(puzzle_list)):
                if goal_positions[puzzle_list[i]] > goal_positions[puzzle_list[j]]:
                    inversions += 1
        return inversions

    def _is_solvable(self) -> bool:
        """Check if the puzzle is solvable"""
        inversions = self._count_inversions(self.initial)

        if self.size % 2 == 1:
            return inversions % 2 == 0
        else:
            blank_row_from_bottom = self.size - (self.initial.index(0) // self.size)
            goal_blank_row = self.size - (self.goal.index(0) // self.size)
            return (inversions + blank_row_from_bottom + goal_blank_row) % 2 == 0

    def _manhattan_distance(self, puzzle: Tuple[int, ...]) -> int:
        """Calculate Manhattan distance heuristic"""
        distance = 0
        for i, val in enumerate(puzzle):
            if val != 0:
                goal_i = self.goal_positions[val]
                current_row, current_col = i // self.size, i % self.size
                goal_row, goal_col = goal_i // self.size, goal_i % self.size
                distance += abs(current_row - goal_row) + abs(current_col - goal_col)
        return distance

    def _hamming_distance(self, puzzle: Tuple[int, ...]) -> int:
        """Calculate Hamming distance (misplaced tiles)"""
        return sum(1 for i, val in enumerate(puzzle) if val != 0 and puzzle[i] != self.goal[i])

    def _linear_conflict(self, puzzle: Tuple[int, ...]) -> int:
        """Calculate Manhattan distance + linear conflict"""
        distance = self._manhattan_distance(puzzle)
        conflict = 0

        # Check rows
        for row in range(self.size):
            row_tiles = []
            for col in range(self.size):
                idx = row * self.size + col
                val = puzzle[idx]
                if val != 0:
                    goal_idx = self.goal_positions[val]
                    goal_row = goal_idx // self.size
                    if goal_row == row:
                        row_tiles.append((col, goal_idx % self.size))

            for i in range(len(row_tiles)):
                for j in range(i + 1, len(row_tiles)):
                    if row_tiles[i][0] > row_tiles[j][0] and row_tiles[i][1] < row_tiles[j][1]:
                        conflict += 2

        # Check columns
        for col in range(self.size):
            col_tiles = []
            for row in range(self.size):
                idx = row * self.size + col
                val = puzzle[idx]
                if val != 0:
                    goal_idx = self.goal_positions[val]
                    goal_col = goal_idx % self.size
                    if goal_col == col:
                        col_tiles.append((row, goal_idx // self.size))

            for i in range(len(col_tiles)):
                for j in range(i + 1, len(col_tiles)):
                    if col_tiles[i][0] > col_tiles[j][0] and col_tiles[i][1] < col_tiles[j][1]:
                        conflict += 2

        return distance + conflict

    def _heuristic(self, puzzle: Tuple[int, ...]) -> int:
        """Calculate heuristic based on selected method"""
        if self.heuristic_name == "hamming":
            return self._hamming_distance(puzzle)
        elif self.heuristic_name == "linear_conflict":
            return self._linear_conflict(puzzle)
        else:  # manhattan (default)
            return self._manhattan_distance(puzzle)

    def _get_neighbors(self, puzzle: Tuple[int, ...]) -> List[Tuple[Tuple[int, ...], str]]:
        """Get all possible moves from current state"""
        neighbors = []
        blank_idx = puzzle.index(0)
        row, col = blank_idx // self.size, blank_idx % self.size

        moves = [
            (-1, 0, "Down"),   # Move tile down (blank up)
            (1, 0, "Up"),      # Move tile up (blank down)
            (0, -1, "Right"),  # Move tile right (blank left)
            (0, 1, "Left"),    # Move tile left (blank right)
        ]

        for dr, dc, move_name in moves:
            new_row, new_col = row + dr, col + dc
            if 0 <= new_row < self.size and 0 <= new_col < self.size:
                new_idx = new_row * self.size + new_col
                puzzle_list = list(puzzle)
                puzzle_list[blank_idx], puzzle_list[new_idx] = puzzle_list[new_idx], puzzle_list[blank_idx]
                neighbors.append((tuple(puzzle_list), move_name))

        return neighbors

    def solve(self) -> Tuple[Optional[List[str]], int, int]:
        """Solve the puzzle using A* algorithm"""
        if self.initial == self.goal:
            return [], 0, 1

        open_set = []
        h = self._heuristic(self.initial)
        initial_state = State(priority=h, puzzle=self.initial, g_cost=0)
        heapq.heappush(open_set, initial_state)

        closed_set: Set[Tuple[int, ...]] = set()
        states_selected = 0
        max_states = 1

        while open_set:
            current = heapq.heappop(open_set)
            states_selected += 1

            if current.puzzle == self.goal:
                # Reconstruct path
                path = []
                state = current
                while state.parent is not None:
                    path.append(state.move)
                    state = state.parent
                return list(reversed(path)), states_selected, max_states

            if current.puzzle in closed_set:
                continue
            closed_set.add(current.puzzle)

            for neighbor_puzzle, move in self._get_neighbors(current.puzzle):
                if neighbor_puzzle in closed_set:
                    continue

                g_cost = current.g_cost + 1
                h_cost = self._heuristic(neighbor_puzzle)
                neighbor_state = State(
                    priority=g_cost + h_cost,
                    puzzle=neighbor_puzzle,
                    g_cost=g_cost,
                    parent=current,
                    move=move
                )
                heapq.heappush(open_set, neighbor_state)

            max_states = max(max_states, len(open_set) + len(closed_set))

        return None, states_selected, max_states


def parse_file(filename: str) -> List[List[int]]:
    """Parse puzzle from file"""
    puzzle = []
    size = None

    with open(filename, 'r') as f:
        for line in f:
            line = line.split('#')[0].strip()
            if not line:
                continue

            numbers = list(map(int, line.split()))
            if size is None:
                if len(numbers) == 1:
                    size = numbers[0]
                    continue
                else:
                    size = len(numbers)
                    puzzle.append(numbers)
            else:
                puzzle.append(numbers)

    if len(puzzle) != size or any(len(row) != size for row in puzzle):
        raise ValueError("Invalid puzzle format")

    return puzzle


def print_puzzle(puzzle: Tuple[int, ...], size: int):
    """Print puzzle in grid format"""
    for i in range(size):
        row = puzzle[i * size:(i + 1) * size]
        print(" ".join(f"{x:2d}" for x in row))


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <puzzle_file> [heuristic]")
        print("Heuristics: manhattan (default), hamming, linear_conflict")
        sys.exit(1)

    filename = sys.argv[1]
    heuristic = sys.argv[2] if len(sys.argv) > 2 else "manhattan"

    try:
        puzzle = parse_file(filename)

        print(f"Initial state (size {len(puzzle)}x{len(puzzle)}):")
        for row in puzzle:
            print(" ".join(f"{x:2d}" for x in row))
        print()

        solver = NPuzzle(puzzle, heuristic)

        print(f"Goal state:")
        print_puzzle(solver.goal, solver.size)
        print()

        print(f"Using heuristic: {heuristic}")
        print("Solving...")

        solution, time_complexity, space_complexity = solver.solve()

        if solution is None:
            print("No solution found!")
        else:
            print(f"\nSolution found!")
            print(f"Number of moves: {len(solution)}")
            print(f"Time complexity (states selected): {time_complexity}")
            print(f"Space complexity (max states in memory): {space_complexity}")
            print(f"\nMoves: {' -> '.join(solution) if solution else 'Already solved'}")

    except FileNotFoundError:
        print(f"Error: File '{filename}' not found")
        sys.exit(1)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
