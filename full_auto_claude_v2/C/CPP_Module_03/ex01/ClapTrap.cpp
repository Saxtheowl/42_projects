/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ClapTrap.cpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ClapTrap.hpp"

ClapTrap::ClapTrap() : name("default"), hitPoints(10), energyPoints(10), attackDamage(0)
{
	std::cout << "ClapTrap default constructor called" << std::endl;
}

ClapTrap::ClapTrap(std::string name) : name(name), hitPoints(10), energyPoints(10), attackDamage(0)
{
	std::cout << "ClapTrap " << this->name << " constructor called" << std::endl;
}

ClapTrap::ClapTrap(const ClapTrap& other)
{
	std::cout << "ClapTrap copy constructor called" << std::endl;
	*this = other;
}

ClapTrap& ClapTrap::operator=(const ClapTrap& other)
{
	std::cout << "ClapTrap copy assignment operator called" << std::endl;
	if (this != &other)
	{
		this->name = other.name;
		this->hitPoints = other.hitPoints;
		this->energyPoints = other.energyPoints;
		this->attackDamage = other.attackDamage;
	}
	return (*this);
}

ClapTrap::~ClapTrap()
{
	std::cout << "ClapTrap " << this->name << " destructor called" << std::endl;
}

void	ClapTrap::attack(const std::string& target)
{
	if (this->energyPoints == 0)
	{
		std::cout << "ClapTrap " << this->name << " has no energy points left to attack!" << std::endl;
		return ;
	}
	if (this->hitPoints == 0)
	{
		std::cout << "ClapTrap " << this->name << " is already dead!" << std::endl;
		return ;
	}
	this->energyPoints--;
	std::cout << "ClapTrap " << this->name << " attacks " << target
			  << ", causing " << this->attackDamage << " points of damage!" << std::endl;
}

void	ClapTrap::takeDamage(unsigned int amount)
{
	if (this->hitPoints == 0)
	{
		std::cout << "ClapTrap " << this->name << " is already dead!" << std::endl;
		return ;
	}
	if (amount >= this->hitPoints)
		this->hitPoints = 0;
	else
		this->hitPoints -= amount;
	std::cout << "ClapTrap " << this->name << " takes " << amount
			  << " points of damage! Hit points left: " << this->hitPoints << std::endl;
}

void	ClapTrap::beRepaired(unsigned int amount)
{
	if (this->energyPoints == 0)
	{
		std::cout << "ClapTrap " << this->name << " has no energy points left to repair!" << std::endl;
		return ;
	}
	if (this->hitPoints == 0)
	{
		std::cout << "ClapTrap " << this->name << " is dead and cannot be repaired!" << std::endl;
		return ;
	}
	this->energyPoints--;
	this->hitPoints += amount;
	std::cout << "ClapTrap " << this->name << " is repaired for " << amount
			  << " hit points! Hit points now: " << this->hitPoints << std::endl;
}
