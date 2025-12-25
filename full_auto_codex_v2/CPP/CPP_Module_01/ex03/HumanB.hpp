#pragma once

#include "Weapon.hpp"

#include <string>

class HumanB
{
public:
	HumanB(const std::string &name);

	void setWeapon(Weapon *weapon);
	void attack() const;

private:
	std::string _name;
	Weapon *_weapon;
};
