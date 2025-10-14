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
	int	N = 5;

	std::cout << "=== Creating a horde of " << N << " zombies ===" << std::endl;
	Zombie*	horde = zombieHorde(N, "HordeZombie");

	if (horde == NULL)
	{
		std::cout << "Failed to create zombie horde" << std::endl;
		return (1);
	}

	std::cout << "\n=== All zombies announce themselves ===" << std::endl;
	for (int i = 0; i < N; i++)
	{
		std::cout << "Zombie " << i << ": ";
		horde[i].announce();
	}

	std::cout << "\n=== Deleting the horde ===" << std::endl;
	delete[] horde;

	std::cout << "\n=== Creating another horde of 10 zombies ===" << std::endl;
	Zombie*	bigHorde = zombieHorde(10, "BigHordeZombie");

	std::cout << "\n=== First 3 zombies announce ===" << std::endl;
	for (int i = 0; i < 3; i++)
	{
		bigHorde[i].announce();
	}

	std::cout << "\n=== Deleting big horde ===" << std::endl;
	delete[] bigHorde;

	return (0);
}
