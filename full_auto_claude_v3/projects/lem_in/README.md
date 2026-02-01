# Lem-in

Ant colony graph traversal optimization.

## Description

Given a graph of rooms connected by tunnels, move N ants from the start room to the end room in the minimum number of turns.

## Features

- BFS-based pathfinding
- Edmonds-Karp algorithm for finding disjoint paths
- Optimal ant distribution across multiple paths
- Parallel movement simulation

## Usage

```bash
./lem_in.py [input_file]

# Or from stdin
cat map.txt | ./lem_in.py
```

## Input Format

```
number_of_ants
##start
start_room x y
##end
end_room x y
room1 x y
room2 x y
...
room1-room2
room2-room3
...
```

## Output Format

Echoes the input, then shows moves per turn:
```
L1-room L2-room ...
```

Where `L1` is ant 1 moving to `room`.

## Example

Input:
```
3
##start
0 1 0
##end
1 5 0
2 9 0
3 13 0
0-2
2-3
3-1
```

Output:
```
L1-2
L1-3 L2-2
L1-1 L2-3 L3-2
L2-1 L3-3
L3-1
```

## Algorithm

1. **Parse** the input to build the graph
2. **Find paths** using Edmonds-Karp (max flow algorithm)
3. **Distribute ants** optimally across paths
4. **Simulate** movement, outputting each turn

## Files

| File | Description |
|------|-------------|
| `lem_in.py` | Main solver |
| `test1.txt` | Simple linear path test |
| `test2.txt` | Multiple paths test |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
