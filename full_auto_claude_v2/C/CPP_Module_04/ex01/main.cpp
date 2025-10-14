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

int main()
{
	std::cout << "=== Test 1: Basic creation and deletion ===" << std::endl;
	const Animal* j = new Dog();
	const Animal* i = new Cat();

	delete j; // should not create a leak
	delete i;

	std::cout << "\n=== Test 2: Array of Animals ===" << std::endl;
	const int size = 10;
	Animal* animals[size];

	std::cout << "\nCreating array (half Dog, half Cat):" << std::endl;
	for (int idx = 0; idx < size; idx++)
	{
		if (idx < size / 2)
			animals[idx] = new Dog();
		else
			animals[idx] = new Cat();
	}

	std::cout << "\nMaking sounds:" << std::endl;
	for (int idx = 0; idx < size; idx++)
		animals[idx]->makeSound();

	std::cout << "\nDeleting array:" << std::endl;
	for (int idx = 0; idx < size; idx++)
		delete animals[idx];

	std::cout << "\n=== Test 3: Deep copy test ===" << std::endl;
	Dog original;

	std::cout << "\nSetting ideas in original dog's brain:" << std::endl;
	original.getBrain()->setIdea(0, "I want to chase cats");
	original.getBrain()->setIdea(1, "I want to eat");
	std::cout << "Original brain idea 0: " << original.getBrain()->getIdea(0) << std::endl;
	std::cout << "Original brain idea 1: " << original.getBrain()->getIdea(1) << std::endl;

	std::cout << "\nCreating a copy:" << std::endl;
	Dog copy(original);

	std::cout << "\nCopy brain idea 0: " << copy.getBrain()->getIdea(0) << std::endl;
	std::cout << "Copy brain idea 1: " << copy.getBrain()->getIdea(1) << std::endl;

	std::cout << "\nModifying copy's brain:" << std::endl;
	copy.getBrain()->setIdea(0, "I want to sleep");
	std::cout << "Copy brain idea 0 (modified): " << copy.getBrain()->getIdea(0) << std::endl;
	std::cout << "Original brain idea 0 (should be unchanged): " << original.getBrain()->getIdea(0) << std::endl;

	std::cout << "\nBrain addresses (should be different for deep copy):" << std::endl;
	std::cout << "Original brain address: " << original.getBrain() << std::endl;
	std::cout << "Copy brain address: " << copy.getBrain() << std::endl;

	std::cout << "\nAutomatic destruction:" << std::endl;

	return 0;
}
