# Rubik

3x3 Rubik's Cube Solver.

## Description

A Rubik's cube solver using BFS (Breadth-First Search) for optimal solutions on short scrambles. Displays the cube state and solution moves.

## Features

- Full 3x3 cube simulation
- All 18 moves (U, D, L, R, F, B and their inverses/doubles)
- BFS solver for optimal solutions
- Unfolded cube display
- Move sequence input/output

## Usage

```bash
./rubik.py 'scramble'    # Solve given scramble
./rubik.py --demo        # Solve demo scramble
```

## Move Notation

| Move | Description |
|------|-------------|
| `U` | Up face clockwise |
| `U'` | Up face counter-clockwise |
| `U2` | Up face 180 degrees |
| `D/D'/D2` | Down face |
| `L/L'/L2` | Left face |
| `R/R'/R2` | Right face |
| `F/F'/F2` | Front face |
| `B/B'/B2` | Back face |

## Example

```bash
$ ./rubik.py "R U R' U'"
Scramble: R U R' U'

Scrambled cube:
      W W O
      W W G
      W W G

B O O  G G Y  R R W  B R R
O O O  G G W  B R R  B B B
O O O  G G G  W R R  B B B

      Y Y R
      Y Y Y
      Y Y Y

Solving...
Solution (4 moves): U R U' R'
Solved!
```

## Cube Display

The cube is shown in unfolded format:
```
      U U U
      U U U
      U U U

L L L  F F F  R R R  B B B
L L L  F F F  R R R  B B B
L L L  F F F  R R R  B B B

      D D D
      D D D
      D D D
```

## Limitations

- BFS solver works best for scrambles up to 6-7 moves
- Longer scrambles may not find solution due to state space
- For production use, implement Kociemba's algorithm

## Files

| File | Description |
|------|-------------|
| `rubik.py` | Main solver |
| `README.md` | Documentation |

## Author

Implementation for 42 curriculum.
