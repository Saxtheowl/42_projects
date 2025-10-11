#include "Cat.hpp"

#include <iostream>

Cat::Cat()
{
    m_type = "Cat";
    std::cout << "Cat constructed" << std::endl;
}

Cat::Cat(const Cat &other)
    : Animal(other)
{
    std::cout << "Cat copy constructed" << std::endl;
}

Cat &Cat::operator=(const Cat &other)
{
    Animal::operator=(other);
    std::cout << "Cat copy assigned" << std::endl;
    return *this;
}

Cat::~Cat()
{
    std::cout << "Cat destroyed" << std::endl;
}

void Cat::makeSound() const
{
    std::cout << "Meow!" << std::endl;
}
