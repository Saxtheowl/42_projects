#pragma once

#include <string>

class Zombie
{
public:
	Zombie();
	~Zombie();

	void setName(const std::string &name);
	void announce() const;

private:
	std::string _name;
};

Zombie *zombieHorde(int N, const std::string &name);
