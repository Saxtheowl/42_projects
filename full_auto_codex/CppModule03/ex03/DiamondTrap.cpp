#include "DiamondTrap.hpp"

#include <iostream>

DiamondTrap::DiamondTrap()
    : ClapTrap("DiamondTrap_clap_name"), ScavTrap("DiamondTrap"), FragTrap("DiamondTrap"), m_name("DiamondTrap")
{
    m_hitPoints = 100;
    m_energyPoints = 50;
    m_attackDamage = 30;
    std::cout << "DiamondTrap default constructed" << std::endl;
}

DiamondTrap::DiamondTrap(const std::string &name)
    : ClapTrap(name + "_clap_name"), ScavTrap(name), FragTrap(name), m_name(name)
{
    m_hitPoints = 100;
    m_energyPoints = 50;
    m_attackDamage = 30;
    std::cout << "DiamondTrap " << m_name << " constructed" << std::endl;
}

DiamondTrap::DiamondTrap(const DiamondTrap &other)
    : ClapTrap(other), ScavTrap(other), FragTrap(other), m_name(other.m_name)
{
    std::cout << "DiamondTrap copy constructed" << std::endl;
}

DiamondTrap &DiamondTrap::operator=(const DiamondTrap &other)
{
    if (this != &other)
    {
        ClapTrap::operator=(other);
        ScavTrap::operator=(other);
        FragTrap::operator=(other);
        m_name = other.m_name;
    }
    std::cout << "DiamondTrap copy assigned" << std::endl;
    return *this;
}

DiamondTrap::~DiamondTrap()
{
    std::cout << "DiamondTrap " << m_name << " destroyed" << std::endl;
}

void DiamondTrap::attack(const std::string &target)
{
    ScavTrap::attack(target);
}

void DiamondTrap::whoAmI() const
{
    std::cout << "DiamondTrap name: " << m_name << ", ClapTrap name: " << ClapTrap::m_name << std::endl;
}
