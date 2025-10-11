#include "FragTrap.hpp"

#include <iostream>

FragTrap::FragTrap()
    : ClapTrap("FragTrap")
{
    m_hitPoints = 100;
    m_energyPoints = 100;
    m_attackDamage = 30;
    std::cout << "FragTrap default constructed" << std::endl;
}

FragTrap::FragTrap(const std::string &name)
    : ClapTrap(name)
{
    m_hitPoints = 100;
    m_energyPoints = 100;
    m_attackDamage = 30;
    std::cout << "FragTrap " << m_name << " constructed" << std::endl;
}

FragTrap::FragTrap(const FragTrap &other)
    : ClapTrap(other)
{
    std::cout << "FragTrap copy constructed" << std::endl;
}

FragTrap &FragTrap::operator=(const FragTrap &other)
{
    ClapTrap::operator=(other);
    std::cout << "FragTrap copy assigned" << std::endl;
    return *this;
}

FragTrap::~FragTrap()
{
    std::cout << "FragTrap " << m_name << " destroyed" << std::endl;
}

void FragTrap::attack(const std::string &target)
{
    if (m_energyPoints <= 0 || m_hitPoints <= 0)
    {
        std::cout << "FragTrap " << m_name << " cannot attack" << std::endl;
        return;
    }
    --m_energyPoints;
    std::cout << "FragTrap " << m_name << " blasts " << target << ", causing "
              << m_attackDamage << " points of damage!" << std::endl;
}

void FragTrap::highFivesGuys() const
{
    std::cout << "FragTrap " << m_name << " requests high fives!" << std::endl;
}
