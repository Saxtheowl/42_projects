#include "Animal.hpp"

#include <iostream>

Animal::Animal() : _type("Animal")
{
	std::cout << "Animal default ctor" << std::endl;
}

Animal::Animal(const Animal &other)
{
	std::cout << "Animal copy ctor" << std::endl;
	*this = other;
}

Animal &Animal::operator=(const Animal &other)
{
	std::cout << "Animal copy assign" << std::endl;
	if (this != &other)
		_type = other._type;
	return *this;
}

Animal::~Animal()
{
	std::cout << "Animal dtor" << std::endl;
}

void Animal::makeSound() const
{
	std::cout << "Generic animal sound" << std::endl;
}

const std::string &Animal::getType() const
{
	return _type;
}
