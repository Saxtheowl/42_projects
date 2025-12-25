#pragma once

#include <string>

class Zombie
{
public:
	Zombie(const std::string &name);
	~Zombie();

	void announce() const;

private:
	std::string _name;
};

Zombie *newZombie(const std::string &name);
void randomChump(const std::string &name);
