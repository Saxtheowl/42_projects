# C++ Modules (00-08)

Complete implementation of 42 C++ piscine modules.

## Modules Overview

| Module | Topics |
|--------|--------|
| cpp00 | Namespaces, classes, member functions, stdio streams, initialization lists, static, const |
| cpp01 | Memory allocation, pointers to members, references, switch statement |
| cpp02 | Ad-hoc polymorphism, operator overloading, Orthodox Canonical class form |
| cpp03 | Inheritance |
| cpp04 | Subtype polymorphism, abstract classes, interfaces |
| cpp05 | Repetition, exceptions |
| cpp06 | C++ casts |
| cpp07 | C++ templates |
| cpp08 | Templated containers, iterators, algorithms |

## Building

Each module has its own Makefile:

```bash
cd cpp_module_XX/ex00
make
./executable_name
```

## Module Structure

```
cpp_modules/
├── cpp_module_00/
│   ├── ex00/  # Megaphone
│   ├── ex01/  # PhoneBook
│   └── ex02/  # Account
├── cpp_module_01/
│   ├── ex00/  # BraiiiiiiinnnzzzZ
│   ├── ex01/  # Moar brainz
│   └── ...
├── cpp_module_02/
│   └── ...    # Fixed point numbers
├── cpp_module_03/
│   └── ...    # ClapTrap, ScavTrap, FragTrap
├── cpp_module_04/
│   └── ...    # Polymorphism, AAnimal
├── cpp_module_05/
│   └── ...    # Bureaucrat exceptions
├── cpp_module_06/
│   └── ...    # Type conversions
├── cpp_module_07/
│   └── ...    # Templates
└── cpp_module_08/
    └── ...    # Containers, iterators
```

## Compilation

All modules compile with:
```bash
c++ -Wall -Wextra -Werror -std=c++98
```

## Author

Implementation for 42 curriculum.
