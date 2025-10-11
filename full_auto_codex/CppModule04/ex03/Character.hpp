#ifndef CHARACTER_HPP
#define CHARACTER_HPP

#include "ICharacter.hpp"
#include "AMateria.hpp"

class Character : public ICharacter
{
private:
    std::string m_name;
    AMateria   *m_inventory[4];
    AMateria   *m_floor[100];

    void clearInventory();
    void cloneFrom(const Character &other);

public:
    Character(const std::string &name);
    Character(const Character &other);
    Character &operator=(const Character &other);
    virtual ~Character();

    virtual const std::string &getName() const;
    virtual void equip(AMateria *m);
    virtual void unequip(int idx);
    virtual void use(int idx, ICharacter &target);
};

#endif
