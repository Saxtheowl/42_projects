# CPP Module 03

## Description

CPP Module 03 covers inheritance in C++: single, multiple, and virtual inheritance.

## Exercises

### ex00 - ClapTrap
Base class with attack, takeDamage, and beRepaired functions.

### ex01 - ScavTrap
Inherits from ClapTrap with different stats and guardGate() ability.

### ex02 - FragTrap
Another ClapTrap child with highFivesGuys() ability.

### ex03 - DiamondTrap
Multiple inheritance from ScavTrap and FragTrap, demonstrating the diamond problem solution with virtual inheritance.

## Key Concepts

- **Single Inheritance**: Deriving from one base class
- **Virtual Destructors**: Required for proper cleanup in polymorphic classes
- **Virtual Inheritance**: Prevents multiple copies of base class in diamond hierarchy

## Compilation

```bash
cd ex00 && make
cd ex01 && make
cd ex02 && make
cd ex03 && make
```

## Author

Implementation for 42 curriculum.
