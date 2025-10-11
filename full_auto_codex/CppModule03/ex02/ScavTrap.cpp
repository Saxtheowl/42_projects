#include "ScavTrap.hpp"

#include <iostream>

ScavTrap::ScavTrap()
    : ClapTrap("ScavTrap")
{
    m_hitPoints = 100;
    m_energyPoints = 50;
    m_attackDamage = 20;
    std::cout << "ScavTrap default constructed" << std::endl;
}

ScavTrap::ScavTrap(const std::string &name)
    : ClapTrap(name)
{
    m_hitPoints = 100;
    m_energyPoints = 50;
    m_attackDamage = 20;
    std::cout << "ScavTrap " << m_name << " constructed" << std::endl;
}

ScavTrap::ScavTrap(const ScavTrap &other)
    : ClapTrap(other)
{
    std::cout << "ScavTrap copy constructed" << std::endl;
}

ScavTrap &ScavTrap::operator=(const ScavTrap &other)
{
    ClapTrap::operator=(other);
    std::cout << "ScavTrap copy assigned" << std::endl;
    return *this;
}

ScavTrap::~ScavTrap()
{
    std::cout << "ScavTrap " << m_name << " destroyed" << std::endl;
}

void ScavTrap::attack(const std::string &target)
{
    if (m_energyPoints <= 0 || m_hitPoints <= 0)
    {
        std::cout << "ScavTrap " << m_name << " cannot attack" << std::endl;
        return;
    }
    --m_energyPoints;
    std::cout << "ScavTrap " << m_name << " slashes " << target << ", causing "
              << m_attackDamage << " points of damage!" << std::endl;
}

void ScavTrap::guardGate()
{
    std::cout << "ScavTrap " << m_name << " is now in Gate keeper mode." << std::endl;
}
