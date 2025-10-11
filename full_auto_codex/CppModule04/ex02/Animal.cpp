#include "Animal.hpp"

#include <iostream>

Animal::Animal()
    : m_type("Animal")
{
    std::cout << "Animal constructed" << std::endl;
}

Animal::Animal(const Animal &other)
    : m_type(other.m_type)
{
    std::cout << "Animal copy constructed" << std::endl;
}

Animal &Animal::operator=(const Animal &other)
{
    if (this != &other)
        m_type = other.m_type;
    std::cout << "Animal copy assigned" << std::endl;
    return *this;
}

Animal::~Animal()
{
    std::cout << "Animal destroyed" << std::endl;
}

const std::string &Animal::getType() const
{
    return m_type;
}

void Animal::makeSound() const
{
    std::cout << "Animal makes an indistinct sound" << std::endl;
}
