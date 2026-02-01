/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ClapTrap.cpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ClapTrap.hpp"

ClapTrap::ClapTrap(void) : _name("default"), _hitPoints(10), _energyPoints(10), _attackDamage(0)
{ std::cout << "ClapTrap default constructor called" << std::endl; }

ClapTrap::ClapTrap(std::string name) : _name(name), _hitPoints(10), _energyPoints(10), _attackDamage(0)
{ std::cout << "ClapTrap " << name << " constructor called" << std::endl; }

ClapTrap::ClapTrap(const ClapTrap& other) { *this = other; }

ClapTrap& ClapTrap::operator=(const ClapTrap& other) {
	if (this != &other) { _name = other._name; _hitPoints = other._hitPoints; _energyPoints = other._energyPoints; _attackDamage = other._attackDamage; }
	return (*this);
}

ClapTrap::~ClapTrap(void) { std::cout << "ClapTrap " << _name << " destructor called" << std::endl; }

void ClapTrap::attack(const std::string& target) {
	if (_hitPoints == 0 || _energyPoints == 0) { std::cout << "ClapTrap " << _name << " has no energy or HP!" << std::endl; return; }
	_energyPoints--;
	std::cout << "ClapTrap " << _name << " attacks " << target << ", causing " << _attackDamage << " damage!" << std::endl;
}

void ClapTrap::takeDamage(unsigned int amount) {
	if (amount >= _hitPoints) _hitPoints = 0; else _hitPoints -= amount;
	std::cout << "ClapTrap " << _name << " takes " << amount << " damage! HP: " << _hitPoints << std::endl;
}

void ClapTrap::beRepaired(unsigned int amount) {
	if (_hitPoints == 0 || _energyPoints == 0) { std::cout << "ClapTrap " << _name << " has no energy or HP!" << std::endl; return; }
	_energyPoints--; _hitPoints += amount;
	std::cout << "ClapTrap " << _name << " repairs for " << amount << " HP! HP: " << _hitPoints << std::endl;
}
