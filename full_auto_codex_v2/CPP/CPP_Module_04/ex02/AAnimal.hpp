#pragma once

#include <string>

class AAnimal
{
public:
	AAnimal();
	AAnimal(const AAnimal &other);
	AAnimal &operator=(const AAnimal &other);
	virtual ~AAnimal();

	virtual void makeSound() const = 0;
	const std::string &getType() const;

protected:
	std::string _type;
};
