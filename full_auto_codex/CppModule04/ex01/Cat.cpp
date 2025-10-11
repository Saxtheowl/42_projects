#include "Cat.hpp"

#include <iostream>

Cat::Cat()
    : m_brain(new Brain())
{
    m_type = "Cat";
    std::cout << "Cat constructed" << std::endl;
}

Cat::Cat(const Cat &other)
    : Animal(other), m_brain(new Brain(*other.m_brain))
{
    std::cout << "Cat copy constructed" << std::endl;
}

Cat &Cat::operator=(const Cat &other)
{
    if (this != &other)
    {
        Animal::operator=(other);
        *m_brain = *other.m_brain;
    }
    std::cout << "Cat copy assigned" << std::endl;
    return *this;
}

Cat::~Cat()
{
    std::cout << "Cat destroyed" << std::endl;
    delete m_brain;
}

void Cat::makeSound() const
{
    std::cout << "Meow!" << std::endl;
}

const Brain &Cat::getBrain() const
{
    return *m_brain;
}

Brain &Cat::getBrain()
{
    return *m_brain;
}
