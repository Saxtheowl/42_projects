/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Dog.hpp"
#include "Cat.hpp"

int	main(void)
{
	Animal*	animals[10];

	for (int i = 0; i < 5; i++)
		animals[i] = new Dog();
	for (int i = 5; i < 10; i++)
		animals[i] = new Cat();

	std::cout << "\n=== Testing deep copy ===" << std::endl;
	Dog	original;
	original.getBrain()->setIdea(0, "Chase the ball!");
	Dog	copy(original);
	std::cout << "Original idea: " << original.getBrain()->getIdea(0) << std::endl;
	std::cout << "Copy idea: " << copy.getBrain()->getIdea(0) << std::endl;
	copy.getBrain()->setIdea(0, "Sleep all day");
	std::cout << "After modifying copy:" << std::endl;
	std::cout << "Original idea: " << original.getBrain()->getIdea(0) << std::endl;
	std::cout << "Copy idea: " << copy.getBrain()->getIdea(0) << std::endl;

	std::cout << "\n=== Deleting animals ===" << std::endl;
	for (int i = 0; i < 10; i++)
		delete animals[i];

	return (0);
}
