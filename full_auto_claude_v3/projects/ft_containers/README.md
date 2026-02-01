# ft_containers

A reimplementation of C++ STL containers in C++98.

## Description

This project implements the following STL containers from scratch:
- **vector**: Dynamic array with automatic resizing
- **list**: Doubly-linked list
- **map**: Red-black tree based associative container
- **stack**: Container adapter (LIFO)
- **queue**: Container adapter (FIFO)

All containers are implemented in the `ft` namespace and follow the C++98 standard.

## Features

### vector
- Dynamic array with contiguous storage
- Random access iterators
- Automatic capacity management
- All standard member functions (push_back, pop_back, insert, erase, resize, reserve, etc.)

### list
- Doubly-linked list
- Bidirectional iterators
- Constant time insertion/removal at any position
- Special member functions: splice, merge, sort, unique, reverse

### map
- Red-black tree implementation
- O(log n) insertion, deletion, and lookup
- Bidirectional iterators (in-order traversal)
- Key-value pairs with unique keys
- lower_bound, upper_bound, equal_range

### stack
- LIFO container adapter
- Uses vector as default underlying container
- push, pop, top, empty, size

### queue
- FIFO container adapter
- Uses list as default underlying container
- push, pop, front, back, empty, size

## Additional Components

- **pair**: Template pair class with make_pair helper
- **iterator_traits**: Iterator traits and categories
- **reverse_iterator**: Reverse iterator adapter

## Compilation

```bash
make
```

## Usage

```bash
./ft_containers
```

## Example Output

```
ft_containers - Testing all containers
=======================================

=== PAIR TESTS ===
p1: (1, one)
p2: (2, two)
p3 (copy of p1): (1, one)
p1 == p3: true
p1 < p2: true

=== VECTOR TESTS ===
Empty vector size: 0
Empty: true
After push_back 10-50:
Size: 5, Capacity: 8
Elements: 10 20 30 40 50
Front: 10, Back: 50
...

=== MAP TESTS ===
Elements (sorted by key):
  five => 5
  four => 4
  one => 1
  three => 3
  two => 2
...
```

## Implementation Details

### Red-Black Tree (for map)
- Self-balancing binary search tree
- Each node is colored RED or BLACK
- Properties maintained:
  1. Every node is either red or black
  2. Root is black
  3. All NIL leaves are black
  4. Red nodes have black children
  5. All paths from root to leaves have the same black depth

### Memory Management
- Uses std::allocator by default
- Proper construction/destruction of elements
- Exception-safe operations

## Files

| File | Description |
|------|-------------|
| `vector.hpp` | Vector container implementation |
| `list.hpp` | List container implementation |
| `map.hpp` | Map container with red-black tree |
| `stack.hpp` | Stack adapter |
| `queue.hpp` | Queue adapter |
| `iterator_traits.hpp` | Iterator traits and reverse_iterator |
| `main.cpp` | Test program |
| `Makefile` | Build configuration |

## Allowed Functions

- All C++98 standard library functions except containers themselves

## Testing

The main.cpp file contains comprehensive tests for all containers:
- Basic operations (insert, erase, access)
- Iterators (forward and reverse)
- Comparison operators
- Special member functions

## Author

Implementation for 42 curriculum.
