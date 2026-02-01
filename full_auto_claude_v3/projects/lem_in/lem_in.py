#!/usr/bin/env python3
"""
Lem-in: Ant Colony Graph Traversal
Move N ants from start to end through a graph in minimum moves.
"""

import sys
from collections import deque
from typing import Dict, List, Set, Tuple, Optional


class Graph:
    def __init__(self):
        self.rooms: Dict[str, Tuple[int, int]] = {}  # name -> (x, y)
        self.links: Dict[str, Set[str]] = {}  # adjacency list
        self.start: Optional[str] = None
        self.end: Optional[str] = None
        self.num_ants: int = 0

    def add_room(self, name: str, x: int, y: int):
        self.rooms[name] = (x, y)
        if name not in self.links:
            self.links[name] = set()

    def add_link(self, room1: str, room2: str):
        if room1 not in self.links:
            self.links[room1] = set()
        if room2 not in self.links:
            self.links[room2] = set()
        self.links[room1].add(room2)
        self.links[room2].add(room1)


def parse_input(lines: List[str]) -> Graph:
    """Parse input file into a Graph."""
    graph = Graph()
    i = 0
    
    # Parse number of ants
    while i < len(lines) and (lines[i].startswith('#') or not lines[i].strip()):
        i += 1
    if i >= len(lines):
        raise ValueError("Missing number of ants")
    graph.num_ants = int(lines[i])
    i += 1
    
    next_is_start = False
    next_is_end = False
    
    # Parse rooms and links
    while i < len(lines):
        line = lines[i].strip()
        i += 1
        
        if not line:
            continue
        if line.startswith("##start"):
            next_is_start = True
            continue
        if line.startswith("##end"):
            next_is_end = True
            continue
        if line.startswith("#"):
            continue
        
        # Check if link (contains -)
        if '-' in line and ' ' not in line:
            parts = line.split('-')
            if len(parts) == 2:
                graph.add_link(parts[0], parts[1])
            continue
        
        # Room definition
        parts = line.split()
        if len(parts) >= 3:
            name = parts[0]
            x, y = int(parts[1]), int(parts[2])
            graph.add_room(name, x, y)
            if next_is_start:
                graph.start = name
                next_is_start = False
            if next_is_end:
                graph.end = name
                next_is_end = False
    
    return graph


def find_disjoint_paths(graph: Graph) -> List[List[str]]:
    """Find non-overlapping paths using Edmonds-Karp (BFS-based max flow)."""
    if not graph.start or not graph.end:
        return []
    
    # Build residual graph
    residual: Dict[str, Dict[str, int]] = {}
    for room in graph.rooms:
        residual[room] = {}
    for room, neighbors in graph.links.items():
        for neighbor in neighbors:
            if room not in residual:
                residual[room] = {}
            if neighbor not in residual:
                residual[neighbor] = {}
            residual[room][neighbor] = 1
            if room not in residual[neighbor]:
                residual[neighbor][room] = 1
    
    paths = []
    
    # Find augmenting paths using BFS
    while True:
        # BFS to find shortest augmenting path
        parent = {graph.start: None}
        queue = deque([graph.start])
        
        while queue and graph.end not in parent:
            current = queue.popleft()
            for neighbor, cap in residual.get(current, {}).items():
                if cap > 0 and neighbor not in parent:
                    parent[neighbor] = current
                    queue.append(neighbor)
        
        if graph.end not in parent:
            break
        
        # Reconstruct path and update residual
        path = []
        node = graph.end
        while node is not None:
            path.append(node)
            prev = parent[node]
            if prev is not None:
                residual[prev][node] -= 1
                if node not in residual:
                    residual[node] = {}
                residual[node][prev] = residual.get(node, {}).get(prev, 0) + 1
            node = prev
        path.reverse()
        paths.append(path)
    
    return paths


def simulate_ants(graph: Graph, paths: List[List[str]]) -> List[List[Tuple[int, str]]]:
    """Simulate ant movement, return moves per turn."""
    if not paths:
        return []
    
    num_ants = graph.num_ants
    # Sort paths by length (shorter first for faster completion)
    paths = sorted(paths, key=len)
    
    # Distribute ants across paths optimally
    ant_assignment: List[List[int]] = [[] for _ in paths]
    
    for ant in range(1, num_ants + 1):
        # Find best path (one that minimizes completion time)
        best_path = 0
        best_time = float('inf')
        for p, path in enumerate(paths):
            # Time = path length - 1 + ants already assigned
            time = len(path) - 1 + len(ant_assignment[p])
            if time < best_time:
                best_time = time
                best_path = p
        ant_assignment[best_path].append(ant)
    
    # State: list of (position_in_path, ant_id) for each path
    # position 0 = start, len(path)-1 = end
    # position -1 = not yet entered the path
    path_states = [[(-1, ant) for ant in ants] for ants in ant_assignment]
    
    turns = []
    ants_finished = 0
    
    while ants_finished < num_ants:
        turn_moves = []
        
        for p_idx, path in enumerate(paths):
            if not path_states[p_idx]:
                continue
            
            new_state = []
            # Process from end to start to avoid blocking
            sorted_state = sorted(path_states[p_idx], key=lambda x: -x[0])
            
            can_enter = True  # Can an ant enter position 1?
            
            for pos, ant_id in sorted_state:
                if pos == len(path) - 1:
                    # Already at end, remove
                    ants_finished += 1
                    continue
                
                if pos >= 0:
                    # Ant is in the path, try to move forward
                    next_pos = pos + 1
                    turn_moves.append((ant_id, path[next_pos]))
                    if next_pos == len(path) - 1:
                        ants_finished += 1
                    else:
                        new_state.append((next_pos, ant_id))
                        if next_pos == 1:
                            can_enter = False
                else:
                    # Ant not yet in path, try to enter at position 1
                    if can_enter:
                        turn_moves.append((ant_id, path[1]))
                        if len(path) == 2:
                            ants_finished += 1
                        else:
                            new_state.append((1, ant_id))
                        can_enter = False
                    else:
                        new_state.append((pos, ant_id))
            
            path_states[p_idx] = new_state
        
        if turn_moves:
            turns.append(turn_moves)
    
    return turns


def solve(input_text: str) -> str:
    """Main solver function."""
    lines = input_text.strip().split('\n')
    graph = parse_input(lines)
    
    if not graph.start or not graph.end:
        return "ERROR: Missing start or end room"
    
    if graph.num_ants < 1:
        return "ERROR: Invalid number of ants"
    
    # Find disjoint paths for parallel movement
    paths = find_disjoint_paths(graph)
    
    if not paths:
        return "ERROR: No path found"
    
    # Simulate ant movement
    turns = simulate_ants(graph, paths)
    
    # Format output
    output_lines = [input_text.strip(), ""]
    for turn in turns:
        line = " ".join(f"L{ant}-{room}" for ant, room in sorted(turn))
        output_lines.append(line)
    
    return "\n".join(output_lines)


def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1], 'r') as f:
            input_text = f.read()
    else:
        input_text = sys.stdin.read()
    
    print(solve(input_text))


if __name__ == "__main__":
    main()
