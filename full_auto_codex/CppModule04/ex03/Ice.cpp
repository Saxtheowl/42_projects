#include "Ice.hpp"
#include "ICharacter.hpp"

#include <iostream>

Ice::Ice()
    : AMateria("ice")
{
    std::cout << "Ice constructed" << std::endl;
}

Ice::Ice(const Ice &other)
    : AMateria(other)
{
    std::cout << "Ice copy constructed" << std::endl;
}

Ice &Ice::operator=(const Ice &other)
{
    AMateria::operator=(other);
    std::cout << "Ice copy assigned" << std::endl;
    return *this;
}

Ice::~Ice()
{
    std::cout << "Ice destroyed" << std::endl;
}

AMateria *Ice::clone() const
{
    return new Ice(*this);
}

void Ice::use(ICharacter &target)
{
    std::cout << "* shoots an ice bolt at " << target.getName() << " *" << std::endl;
}
