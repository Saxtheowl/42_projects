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

#include "DiamondTrap.hpp"

int main( void )
{
	std::cout << "=== Creating DiamondTraps ===" << std::endl;
	DiamondTrap diamond1("DT-001");
	DiamondTrap diamond2("DT-002");

	std::cout << "\n=== Testing whoAmI ===" << std::endl;
	diamond1.whoAmI();
	diamond2.whoAmI();

	std::cout << "\n=== Testing attack (from ScavTrap) ===" << std::endl;
	diamond1.attack("Enemy1");
	diamond2.attack("Enemy2");

	std::cout << "\n=== Testing takeDamage ===" << std::endl;
	diamond1.takeDamage(50);

	std::cout << "\n=== Testing beRepaired ===" << std::endl;
	diamond1.beRepaired(30);

	std::cout << "\n=== Testing inherited methods ===" << std::endl;
	diamond1.guardGate();
	diamond2.highFivesGuys();

	std::cout << "\n=== Testing copy constructor ===" << std::endl;
	DiamondTrap diamond3(diamond1);
	diamond3.whoAmI();

	std::cout << "\n=== Testing copy assignment ===" << std::endl;
	DiamondTrap diamond4;
	diamond4 = diamond2;
	diamond4.whoAmI();

	std::cout << "\n=== Destructors ===" << std::endl;
	return 0;
}
