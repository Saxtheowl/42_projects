# CPP Module 05

## Description

CPP Module 05 covers exception handling in C++.

## Exercises

### ex00 - Bureaucrat
Bureaucrat class with grade (1-150), throws exceptions on invalid grades.

### ex01 - Form
Form class that can be signed by Bureaucrat if grade is sufficient.

### ex02 - Concrete Forms
Three concrete form types:
- ShrubberyCreationForm: Creates ASCII tree file
- RobotomyRequestForm: 50% success robotomy
- PresidentialPardonForm: Presidential pardon

### ex03 - Intern
Intern class that can create any form type by name.

## Key Concepts

- **try/catch**: Exception handling blocks
- **throw**: Raising exceptions
- **Custom exceptions**: Inheriting from std::exception

## Compilation

```bash
cd ex00 && make
cd ex01 && make
cd ex02 && make
cd ex03 && make
```

## Author

Implementation for 42 curriculum.
