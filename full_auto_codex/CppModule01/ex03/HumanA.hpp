#ifndef HUMANA_HPP
#define HUMANA_HPP

#include "Weapon.hpp"

#include <string>

class HumanA
{
private:
    std::string m_name;
    Weapon &m_weapon;

public:
    HumanA(const std::string &name, Weapon &weapon);
    void attack() const;
};

#endif
