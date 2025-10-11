#include "AMateria.hpp"
#include "ICharacter.hpp"

#include <iostream>

AMateria::AMateria(const std::string &type)
    : m_type(type)
{
    std::cout << "AMateria of type " << m_type << " constructed" << std::endl;
}

AMateria::AMateria(const AMateria &other)
    : m_type(other.m_type)
{
    std::cout << "AMateria copy constructed" << std::endl;
}

AMateria &AMateria::operator=(const AMateria &other)
{
    if (this != &other)
        m_type = other.m_type;
    std::cout << "AMateria copy assigned" << std::endl;
    return *this;
}

AMateria::~AMateria()
{
    std::cout << "AMateria of type " << m_type << " destroyed" << std::endl;
}

const std::string &AMateria::getType() const
{
    return m_type;
}

void AMateria::use(ICharacter &target)
{
    (void)target;
    std::cout << "* uses materia of type " << m_type << " *" << std::endl;
}
