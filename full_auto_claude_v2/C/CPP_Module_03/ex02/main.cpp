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

#include "FragTrap.hpp"

int main( void )
{
	std::cout << "=== Creating FragTraps ===" << std::endl;
	FragTrap frag1("FT-001");
	FragTrap frag2("FT-002");

	std::cout << "\n=== Testing FragTrap attack ===" << std::endl;
	frag1.attack("Enemy1");
	frag1.attack("Enemy2");

	std::cout << "\n=== Testing takeDamage ===" << std::endl;
	frag2.takeDamage(40);
	frag2.takeDamage(30);

	std::cout << "\n=== Testing beRepaired ===" << std::endl;
	frag2.beRepaired(35);

	std::cout << "\n=== Testing highFivesGuys ===" << std::endl;
	frag1.highFivesGuys();
	frag2.highFivesGuys();

	std::cout << "\n=== Testing copy constructor ===" << std::endl;
	FragTrap frag3(frag1);

	std::cout << "\n=== Testing copy assignment ===" << std::endl;
	FragTrap frag4;
	frag4 = frag2;

	std::cout << "\n=== Testing ClapTrap ===" << std::endl;
	ClapTrap clap("CT-001");
	clap.attack("Target");

	std::cout << "\n=== Destructors ===" << std::endl;
	return 0;
}
