#include "WrongAnimal.hpp"

#include <iostream>

WrongAnimal::WrongAnimal()
    : m_type("WrongAnimal")
{
    std::cout << "WrongAnimal constructed" << std::endl;
}

WrongAnimal::WrongAnimal(const WrongAnimal &other)
    : m_type(other.m_type)
{
    std::cout << "WrongAnimal copy constructed" << std::endl;
}

WrongAnimal &WrongAnimal::operator=(const WrongAnimal &other)
{
    if (this != &other)
        m_type = other.m_type;
    std::cout << "WrongAnimal copy assigned" << std::endl;
    return *this;
}

WrongAnimal::~WrongAnimal()
{
    std::cout << "WrongAnimal destroyed" << std::endl;
}

const std::string &WrongAnimal::getType() const
{
    return m_type;
}

void WrongAnimal::makeSound() const
{
    std::cout << "WrongAnimal makes a generic wrong sound" << std::endl;
}
