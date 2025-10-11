#ifndef HUMANB_HPP
#define HUMANB_HPP

#include "Weapon.hpp"

#include <string>

class HumanB
{
private:
    std::string m_name;
    Weapon *m_weapon;

public:
    explicit HumanB(const std::string &name);

    void setWeapon(Weapon &weapon);
    void attack() const;
};

#endif
