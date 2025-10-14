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

#include "ClapTrap.hpp"

int main( void )
{
	std::cout << "=== Creating ClapTraps ===" << std::endl;
	ClapTrap clap1("CT-001");
	ClapTrap clap2("CT-002");

	std::cout << "\n=== Testing attack ===" << std::endl;
	clap1.attack("Enemy1");
	clap1.attack("Enemy2");

	std::cout << "\n=== Testing takeDamage ===" << std::endl;
	clap2.takeDamage(5);
	clap2.takeDamage(3);

	std::cout << "\n=== Testing beRepaired ===" << std::endl;
	clap2.beRepaired(4);

	std::cout << "\n=== Testing energy depletion ===" << std::endl;
	for (int i = 0; i < 10; i++)
		clap1.attack("Target");

	std::cout << "\n=== Testing death ===" << std::endl;
	clap2.takeDamage(20);
	clap2.attack("Target");
	clap2.beRepaired(5);

	std::cout << "\n=== Testing copy constructor ===" << std::endl;
	ClapTrap clap3(clap1);

	std::cout << "\n=== Testing copy assignment ===" << std::endl;
	ClapTrap clap4;
	clap4 = clap2;

	std::cout << "\n=== Destructors ===" << std::endl;
	return 0;
}
