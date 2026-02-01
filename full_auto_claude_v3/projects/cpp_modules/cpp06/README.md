# CPP Module 06

## Description

CPP Module 06 covers C++ casts: static_cast, reinterpret_cast, and dynamic_cast.

## Exercises

### ex00 - ScalarConverter
Converts string literals to char, int, float, and double using static_cast.

### ex01 - Serializer
Uses reinterpret_cast to serialize/deserialize pointers.

### ex02 - Identify real type
Uses dynamic_cast to identify the real type of a polymorphic class.

## Key Concepts

- **static_cast**: Compile-time cast for related types
- **reinterpret_cast**: Low-level bit reinterpretation
- **dynamic_cast**: Runtime type identification for polymorphic classes

## Compilation

```bash
cd ex00 && make && ./convert 42.0f
cd ex01 && make && ./serialize
cd ex02 && make && ./identify
```

## Author

Implementation for 42 curriculum.
