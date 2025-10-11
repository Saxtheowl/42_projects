#include "WrongCat.hpp"

#include <iostream>

WrongCat::WrongCat()
{
    m_type = "WrongCat";
    std::cout << "WrongCat constructed" << std::endl;
}

WrongCat::WrongCat(const WrongCat &other)
    : WrongAnimal(other)
{
    std::cout << "WrongCat copy constructed" << std::endl;
}

WrongCat &WrongCat::operator=(const WrongCat &other)
{
    WrongAnimal::operator=(other);
    std::cout << "WrongCat copy assigned" << std::endl;
    return *this;
}

WrongCat::~WrongCat()
{
    std::cout << "WrongCat destroyed" << std::endl;
}

void WrongCat::makeSound() const
{
    std::cout << "Meeeow?" << std::endl;
}
