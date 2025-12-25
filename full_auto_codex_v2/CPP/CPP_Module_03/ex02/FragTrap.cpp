#include "FragTrap.hpp"

#include <iostream>

FragTrap::FragTrap() : ClapTrap("FragDefault")
{
	_hitPoints = 100;
	_energyPoints = 100;
	_attackDamage = 30;
	std::cout << "FragTrap default ctor" << std::endl;
}

FragTrap::FragTrap(const std::string &name) : ClapTrap(name)
{
	_hitPoints = 100;
	_energyPoints = 100;
	_attackDamage = 30;
	std::cout << "FragTrap name ctor" << std::endl;
}

FragTrap::FragTrap(const FragTrap &other) : ClapTrap(other)
{
	std::cout << "FragTrap copy ctor" << std::endl;
	*this = other;
}

FragTrap &FragTrap::operator=(const FragTrap &other)
{
	std::cout << "FragTrap copy assign" << std::endl;
	if (this != &other)
	{
		ClapTrap::operator=(other);
	}
	return *this;
}

FragTrap::~FragTrap()
{
	std::cout << "FragTrap dtor" << std::endl;
}

void FragTrap::attack(const std::string &target)
{
	if (_energyPoints <= 0 || _hitPoints <= 0)
	{
		std::cout << "FragTrap " << _name << " cannot attack" << std::endl;
		return;
	}
	std::cout << "FragTrap " << _name << " attacks " << target << " for " << _attackDamage << " dmg" << std::endl;
	--_energyPoints;
}

void FragTrap::highFivesGuys()
{
	std::cout << "FragTrap " << _name << " requests high fives!" << std::endl;
}
