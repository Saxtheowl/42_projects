# CPP Module 02

## Description

CPP Module 02 covers ad-hoc polymorphism, operator overloading, and the Orthodox Canonical Form in C++.

## Key Concepts

- **Orthodox Canonical Form**: Default constructor, copy constructor, copy assignment operator, destructor
- **Fixed-point numbers**: Representation of fractional values using integers
- **Operator overloading**: Customizing operators for user-defined types

## Exercises

### ex00 - My First Class in Orthodox Canonical Form
Basic Fixed class with:
- Private value and fractional bits
- Copy constructor and assignment operator
- getRawBits/setRawBits functions

### ex01 - Towards a more useful fixed-point number class
Enhanced Fixed class with:
- Constructors from int and float
- toFloat() and toInt() conversions
- Overloaded << operator for output

### ex02 - Now we're talking
Full operator overloading:
- Comparison operators: >, <, >=, <=, ==, !=
- Arithmetic operators: +, -, *, /
- Increment/decrement: ++, -- (pre and post)
- Static min/max functions

### ex03 - BSP (Binary Space Partitioning)
Point-in-triangle test using Fixed:
- Point class with const x, y coordinates
- bsp() function using cross product method
- Returns true only if point is strictly inside triangle

## Compilation

```bash
cd ex00 && make
cd ex01 && make
cd ex02 && make
cd ex03 && make
```

## Usage

```bash
# ex00-02
./fixed

# ex03
./bsp
```

## Author

Implementation for 42 curriculum.
