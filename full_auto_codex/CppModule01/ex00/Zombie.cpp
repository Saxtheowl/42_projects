#include "Zombie.hpp"

#include <iostream>

Zombie::Zombie(const std::string &name)
    : m_name(name)
{
}

Zombie::~Zombie()
{
    std::cout << m_name << ": was destroyed" << std::endl;
}

void Zombie::announce() const
{
    std::cout << m_name << ": BraiiiiiiinnnzzzZ..." << std::endl;
}
