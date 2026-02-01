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

#include "Zombie.hpp"

int	main(void)
{
	int		N = 5;
	Zombie*	horde = zombieHorde(N, "HordeZombie");

	std::cout << "=== Announcing the horde ===" << std::endl;
	for (int i = 0; i < N; i++)
		horde[i].announce();

	std::cout << "\n=== Deleting the horde ===" << std::endl;
	delete[] horde;

	return (0);
}
