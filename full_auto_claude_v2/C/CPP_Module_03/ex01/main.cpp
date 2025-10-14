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

#include "ScavTrap.hpp"

int main( void )
{
	std::cout << "=== Creating ScavTraps ===" << std::endl;
	ScavTrap scav1("ST-001");
	ScavTrap scav2("ST-002");

	std::cout << "\n=== Testing ScavTrap attack (overridden) ===" << std::endl;
	scav1.attack("Enemy1");
	scav1.attack("Enemy2");

	std::cout << "\n=== Testing takeDamage ===" << std::endl;
	scav2.takeDamage(30);
	scav2.takeDamage(20);

	std::cout << "\n=== Testing beRepaired ===" << std::endl;
	scav2.beRepaired(25);

	std::cout << "\n=== Testing guardGate ===" << std::endl;
	scav1.guardGate();
	scav2.guardGate();

	std::cout << "\n=== Testing copy constructor ===" << std::endl;
	ScavTrap scav3(scav1);

	std::cout << "\n=== Testing copy assignment ===" << std::endl;
	ScavTrap scav4;
	scav4 = scav2;

	std::cout << "\n=== Testing ClapTrap ===" << std::endl;
	ClapTrap clap("CT-001");
	clap.attack("Target");

	std::cout << "\n=== Destructors ===" << std::endl;
	return 0;
}
