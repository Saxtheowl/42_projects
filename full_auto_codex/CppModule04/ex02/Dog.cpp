#include "Dog.hpp"

#include <iostream>

Dog::Dog()
    : m_brain(new Brain())
{
    m_type = "Dog";
    std::cout << "Dog constructed" << std::endl;
}

Dog::Dog(const Dog &other)
    : Animal(other), m_brain(new Brain(*other.m_brain))
{
    std::cout << "Dog copy constructed" << std::endl;
}

Dog &Dog::operator=(const Dog &other)
{
    if (this != &other)
    {
        Animal::operator=(other);
        *m_brain = *other.m_brain;
    }
    std::cout << "Dog copy assigned" << std::endl;
    return *this;
}

Dog::~Dog()
{
    std::cout << "Dog destroyed" << std::endl;
    delete m_brain;
}

void Dog::makeSound() const
{
    std::cout << "Woof!" << std::endl;
}

const Brain &Dog::getBrain() const
{
    return *m_brain;
}

Brain &Dog::getBrain()
{
    return *m_brain;
}
