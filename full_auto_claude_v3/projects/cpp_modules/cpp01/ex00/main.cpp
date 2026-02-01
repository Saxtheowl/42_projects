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
	std::cout << "=== Creating zombie on heap ===" << std::endl;
	Zombie*	heapZombie = newZombie("HeapZombie");
	heapZombie->announce();

	std::cout << "\n=== Creating zombie on stack (randomChump) ===" << std::endl;
	randomChump("StackZombie");

	std::cout << "\n=== Deleting heap zombie ===" << std::endl;
	delete heapZombie;

	return (0);
}
