# CPP Module 04

## Description

CPP Module 04 covers subtype polymorphism, abstract classes, and interfaces in C++.

## Exercises

### ex00 - Polymorphism
Basic Animal/Dog/Cat hierarchy with virtual makeSound().
Shows difference between virtual and non-virtual (WrongAnimal/WrongCat).

### ex01 - I don't want to set the world on fire
Deep copy implementation with Brain class.
Dog and Cat have a Brain pointer that must be deep copied.

### ex02 - Abstract class
Makes Animal abstract (AAnimal) by declaring makeSound() as pure virtual.
Prevents instantiation of the base class.

### ex03 - Interface & recap
Full interface-based design:
- ICharacter: Interface for characters
- IMateriaSource: Interface for materia creation
- AMateria: Abstract base for Ice and Cure
- Character: Concrete implementation with inventory

## Key Concepts

- **Virtual Functions**: Enable runtime polymorphism
- **Pure Virtual (= 0)**: Makes class abstract
- **Interfaces**: Classes with only pure virtual functions
- **Deep Copy**: Cloning dynamically allocated members

## Compilation

```bash
cd ex00 && make
cd ex01 && make
cd ex02 && make
cd ex03 && make
```

## Author

Implementation for 42 curriculum.
