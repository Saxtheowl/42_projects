/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Animal.hpp"
#include "Dog.hpp"
#include "Cat.hpp"
#include "WrongAnimal.hpp"
#include "WrongCat.hpp"

int main()
{
	std::cout << "=== Test 1: Correct Polymorphism ===" << std::endl;
	const Animal* meta = new Animal();
	const Animal* j = new Dog();
	const Animal* i = new Cat();

	std::cout << "\nType tests:" << std::endl;
	std::cout << "j type: " << j->getType() << std::endl;
	std::cout << "i type: " << i->getType() << std::endl;

	std::cout << "\nSound tests (should show Dog and Cat sounds):" << std::endl;
	i->makeSound(); // Will output the cat sound!
	j->makeSound(); // Will output the dog sound!
	meta->makeSound(); // Will output the animal sound

	std::cout << "\nDeleting correct animals:" << std::endl;
	delete meta;
	delete j;
	delete i;

	std::cout << "\n=== Test 2: Wrong Polymorphism (no virtual) ===" << std::endl;
	const WrongAnimal* wrongMeta = new WrongAnimal();
	const WrongAnimal* wrongCat = new WrongCat();

	std::cout << "\nType test:" << std::endl;
	std::cout << "wrongCat type: " << wrongCat->getType() << std::endl;

	std::cout << "\nSound test (should show WrongAnimal sound, not WrongCat!):" << std::endl;
	wrongCat->makeSound(); // Will output WrongAnimal sound (NOT polymorphic!)
	wrongMeta->makeSound();

	std::cout << "\nDeleting wrong animals:" << std::endl;
	delete wrongMeta;
	delete wrongCat;

	std::cout << "\n=== Test 3: Direct instantiation ===" << std::endl;
	Dog dog;
	Cat cat;

	std::cout << "\nDirect sound tests:" << std::endl;
	dog.makeSound();
	cat.makeSound();

	std::cout << "\nAutomatic destruction:" << std::endl;

	return 0;
}
