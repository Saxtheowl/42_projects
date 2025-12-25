#include "AAnimal.hpp"

#include <iostream>

AAnimal::AAnimal() : _type("AAnimal")
{
	std::cout << "AAnimal default ctor" << std::endl;
}

AAnimal::AAnimal(const AAnimal &other)
{
	std::cout << "AAnimal copy ctor" << std::endl;
	*this = other;
}

AAnimal &AAnimal::operator=(const AAnimal &other)
{
	std::cout << "AAnimal copy assign" << std::endl;
	if (this != &other)
		_type = other._type;
	return *this;
}

AAnimal::~AAnimal()
{
	std::cout << "AAnimal dtor" << std::endl;
}

const std::string &AAnimal::getType() const
{
	return _type;
}
