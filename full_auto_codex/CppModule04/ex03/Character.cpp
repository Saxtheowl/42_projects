#include "Character.hpp"

#include <iostream>

Character::Character(const std::string &name)
    : m_name(name)
{
    std::cout << "Character " << m_name << " constructed" << std::endl;
    for (int i = 0; i < 4; ++i)
        m_inventory[i] = 0;
    for (int i = 0; i < 100; ++i)
        m_floor[i] = 0;
}

Character::Character(const Character &other)
    : m_name(other.m_name)
{
    std::cout << "Character copy constructed" << std::endl;
    for (int i = 0; i < 4; ++i)
        m_inventory[i] = 0;
    for (int i = 0; i < 100; ++i)
        m_floor[i] = 0;
    cloneFrom(other);
}

Character &Character::operator=(const Character &other)
{
    if (this != &other)
    {
        clearInventory();
        m_name = other.m_name;
        cloneFrom(other);
    }
    std::cout << "Character copy assigned" << std::endl;
    return *this;
}

Character::~Character()
{
    std::cout << "Character " << m_name << " destroyed" << std::endl;
    clearInventory();
}

void Character::clearInventory()
{
    for (int i = 0; i < 4; ++i)
    {
        delete m_inventory[i];
        m_inventory[i] = 0;
    }
    for (int i = 0; i < 100; ++i)
    {
        delete m_floor[i];
        m_floor[i] = 0;
    }
}

void Character::cloneFrom(const Character &other)
{
    for (int i = 0; i < 4; ++i)
    {
        if (other.m_inventory[i])
            m_inventory[i] = other.m_inventory[i]->clone();
        else
            m_inventory[i] = 0;
    }
}

const std::string &Character::getName() const
{
    return m_name;
}

void Character::equip(AMateria *m)
{
    if (!m)
        return;
    for (int i = 0; i < 4; ++i)
    {
        if (!m_inventory[i])
        {
            m_inventory[i] = m;
            std::cout << m_name << " equips " << m->getType() << " in slot " << i << std::endl;
            return;
        }
    }
    for (int i = 0; i < 100; ++i)
    {
        if (!m_floor[i])
        {
            m_floor[i] = m;
            std::cout << m_name << " drops excess materia on the floor" << std::endl;
            return;
        }
    }
    delete m;
}

void Character::unequip(int idx)
{
    if (idx < 0 || idx >= 4 || !m_inventory[idx])
        return;
    for (int i = 0; i < 100; ++i)
    {
        if (!m_floor[i])
        {
            m_floor[i] = m_inventory[idx];
            std::cout << m_name << " unequips slot " << idx << std::endl;
            m_inventory[idx] = 0;
            return;
        }
    }
    std::cout << m_name << " drops materia and it vanishes" << std::endl;
    delete m_inventory[idx];
    m_inventory[idx] = 0;
}

void Character::use(int idx, ICharacter &target)
{
    if (idx < 0 || idx >= 4 || !m_inventory[idx])
        return;
    m_inventory[idx]->use(target);
}
