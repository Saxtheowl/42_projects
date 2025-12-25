#include "Dog.hpp"

#include <iostream>

Dog::Dog() : _brain(new Brain())
{
	_type = "Dog";
	std::cout << "Dog ctor" << std::endl;
}

Dog::Dog(const Dog &other) : Animal(other), _brain(new Brain(*other._brain))
{
	std::cout << "Dog copy ctor" << std::endl;
}

Dog &Dog::operator=(const Dog &other)
{
	std::cout << "Dog copy assign" << std::endl;
	if (this != &other)
	{
		Animal::operator=(other);
		* _brain = *other._brain;
	}
	return *this;
}

Dog::~Dog()
{
	std::cout << "Dog dtor" << std::endl;
	delete _brain;
}

void Dog::makeSound() const
{
	std::cout << "Woof!" << std::endl;
}
