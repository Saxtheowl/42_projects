#include "AAnimal.hpp"
#include "Cat.hpp"
#include "Dog.hpp"

#include <iostream>

int main()
{
	const int size = 4;
	AAnimal *animals[size];
	for (int i = 0; i < size; ++i)
	{
		if (i % 2 == 0)
			animals[i] = new Dog();
		else
			animals[i] = new Cat();
	}

	for (int i = 0; i < size; ++i)
	{
		std::cout << animals[i]->getType() << " sound: ";
		animals[i]->makeSound();
	}

	Dog basic;
	Dog copy = basic;
	basic.makeSound();
	copy.makeSound();

	for (int i = 0; i < size; ++i)
		delete animals[i];
	return 0;
}
