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

#include "Zombie.hpp"

int	main(void)
{
	std::cout << "=== Testing newZombie (heap allocation) ===" << std::endl;
	Zombie*	heapZombie = newZombie("HeapZombie");
	heapZombie->announce();
	delete heapZombie;

	std::cout << "\n=== Testing randomChump (stack allocation) ===" << std::endl;
	randomChump("StackZombie");

	std::cout << "\n=== Creating multiple heap zombies ===" << std::endl;
	Zombie*	z1 = newZombie("Zombie1");
	Zombie*	z2 = newZombie("Zombie2");
	Zombie*	z3 = newZombie("Zombie3");

	z1->announce();
	z2->announce();
	z3->announce();

	delete z1;
	delete z2;
	delete z3;

	std::cout << "\n=== Program ending ===" << std::endl;
	return (0);
}
