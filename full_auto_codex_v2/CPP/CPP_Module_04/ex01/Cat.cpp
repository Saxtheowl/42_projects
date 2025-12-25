#include "Cat.hpp"

#include <iostream>

Cat::Cat() : _brain(new Brain())
{
	_type = "Cat";
	std::cout << "Cat ctor" << std::endl;
}

Cat::Cat(const Cat &other) : Animal(other), _brain(new Brain(*other._brain))
{
	std::cout << "Cat copy ctor" << std::endl;
}

Cat &Cat::operator=(const Cat &other)
{
	std::cout << "Cat copy assign" << std::endl;
	if (this != &other)
	{
		Animal::operator=(other);
		*_brain = *other._brain;
	}
	return *this;
}

Cat::~Cat()
{
	std::cout << "Cat dtor" << std::endl;
	delete _brain;
}

void Cat::makeSound() const
{
	std::cout << "Meow!" << std::endl;
}
