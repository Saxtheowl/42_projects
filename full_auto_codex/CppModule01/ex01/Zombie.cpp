#include "Zombie.hpp"

#include <iostream>

Zombie::Zombie()
{
}

Zombie::Zombie(const std::string &name)
    : m_name(name)
{
}

Zombie::~Zombie()
{
    std::cout << m_name << ": destroyed" << std::endl;
}

void Zombie::setName(const std::string &name)
{
    m_name = name;
}

void Zombie::announce() const
{
    std::cout << m_name << ": BraiiiiiiinnnzzzZ..." << std::endl;
}
