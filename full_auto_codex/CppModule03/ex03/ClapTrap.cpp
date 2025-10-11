#include "ClapTrap.hpp"

#include <iostream>

ClapTrap::ClapTrap()
    : m_name("ClapTrap"), m_hitPoints(10), m_energyPoints(10), m_attackDamage(0)
{
    std::cout << "ClapTrap default constructed" << std::endl;
}

ClapTrap::ClapTrap(const std::string &name)
    : m_name(name), m_hitPoints(10), m_energyPoints(10), m_attackDamage(0)
{
    std::cout << "ClapTrap " << m_name << " constructed" << std::endl;
}

ClapTrap::ClapTrap(const ClapTrap &other)
    : m_name(other.m_name),
      m_hitPoints(other.m_hitPoints),
      m_energyPoints(other.m_energyPoints),
      m_attackDamage(other.m_attackDamage)
{
    std::cout << "ClapTrap copy constructed" << std::endl;
}

ClapTrap &ClapTrap::operator=(const ClapTrap &other)
{
    if (this != &other)
    {
        m_name = other.m_name;
        m_hitPoints = other.m_hitPoints;
        m_energyPoints = other.m_energyPoints;
        m_attackDamage = other.m_attackDamage;
    }
    std::cout << "ClapTrap copy assigned" << std::endl;
    return *this;
}

ClapTrap::~ClapTrap()
{
    std::cout << "ClapTrap " << m_name << " destroyed" << std::endl;
}

void ClapTrap::attack(const std::string &target)
{
    if (m_energyPoints <= 0 || m_hitPoints <= 0)
    {
        std::cout << "ClapTrap " << m_name << " cannot attack" << std::endl;
        return;
    }
    --m_energyPoints;
    std::cout << "ClapTrap " << m_name << " attacks " << target << ", causing "
              << m_attackDamage << " points of damage!" << std::endl;
}

void ClapTrap::takeDamage(unsigned int amount)
{
    m_hitPoints -= static_cast<int>(amount);
    if (m_hitPoints < 0)
        m_hitPoints = 0;
    std::cout << "ClapTrap " << m_name << " takes " << amount
              << " damage, HP now " << m_hitPoints << std::endl;
}

void ClapTrap::beRepaired(unsigned int amount)
{
    if (m_energyPoints <= 0 || m_hitPoints <= 0)
    {
        std::cout << "ClapTrap " << m_name << " cannot repair" << std::endl;
        return;
    }
    --m_energyPoints;
    m_hitPoints += static_cast<int>(amount);
    std::cout << "ClapTrap " << m_name << " repairs " << amount
              << " HP, now " << m_hitPoints << std::endl;
}
