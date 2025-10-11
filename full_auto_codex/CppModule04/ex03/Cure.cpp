#include "Cure.hpp"
#include "ICharacter.hpp"

#include <iostream>

Cure::Cure()
    : AMateria("cure")
{
    std::cout << "Cure constructed" << std::endl;
}

Cure::Cure(const Cure &other)
    : AMateria(other)
{
    std::cout << "Cure copy constructed" << std::endl;
}

Cure &Cure::operator=(const Cure &other)
{
    AMateria::operator=(other);
    std::cout << "Cure copy assigned" << std::endl;
    return *this;
}

Cure::~Cure()
{
    std::cout << "Cure destroyed" << std::endl;
}

AMateria *Cure::clone() const
{
    return new Cure(*this);
}

void Cure::use(ICharacter &target)
{
    std::cout << "* heals " << target.getName() << "'s wounds *" << std::endl;
}
