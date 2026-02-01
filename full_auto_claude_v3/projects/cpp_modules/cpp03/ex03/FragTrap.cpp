/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   FragTrap.cpp                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "FragTrap.hpp"

FragTrap::FragTrap(void) : ClapTrap() { _hitPoints = 100; _energyPoints = 100; _attackDamage = 30; std::cout << "FragTrap default constructor called" << std::endl; }
FragTrap::FragTrap(std::string name) : ClapTrap(name) { _hitPoints = 100; _energyPoints = 100; _attackDamage = 30; std::cout << "FragTrap " << name << " constructor called" << std::endl; }
FragTrap::FragTrap(const FragTrap& other) : ClapTrap(other) {}
FragTrap& FragTrap::operator=(const FragTrap& other) { ClapTrap::operator=(other); return (*this); }
FragTrap::~FragTrap(void) { std::cout << "FragTrap " << _name << " destructor called" << std::endl; }
void FragTrap::highFivesGuys(void) { std::cout << "FragTrap " << _name << " requests a high five!" << std::endl; }
