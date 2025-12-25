#include "Zombie.hpp"

#include <iostream>

Zombie::Zombie(const std::string &name) : _name(name) {}

Zombie::~Zombie()
{
	std::cout << _name << " is destroyed" << std::endl;
}

void Zombie::announce() const
{
	std::cout << _name << ": BraiiiiiiinnnzzzZ..." << std::endl;
}

Zombie *newZombie(const std::string &name)
{
	return new Zombie(name);
}

void randomChump(const std::string &name)
{
	Zombie z(name);
	z.announce();
}
