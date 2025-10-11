#include "HumanB.hpp"

#include <iostream>

HumanB::HumanB(const std::string &name)
    : m_name(name), m_weapon(0)
{
}

void HumanB::setWeapon(Weapon &weapon)
{
    m_weapon = &weapon;
}

void HumanB::attack() const
{
    if (m_weapon)
        std::cout << m_name << " attacks with their " << m_weapon->getType() << std::endl;
    else
        std::cout << m_name << " has no weapon" << std::endl;
}
