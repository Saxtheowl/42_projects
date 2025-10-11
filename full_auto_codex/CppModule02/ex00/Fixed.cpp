#include "Fixed.hpp"

#include <iostream>

const int Fixed::s_fractionalBits = 8;

Fixed::Fixed()
    : m_raw(0)
{
    std::cout << "Default constructor called" << std::endl;
}

Fixed::Fixed(const Fixed &other)
    : m_raw(other.m_raw)
{
    std::cout << "Copy constructor called" << std::endl;
}

Fixed &Fixed::operator=(const Fixed &other)
{
    std::cout << "Copy assignment operator called" << std::endl;
    if (this != &other)
        m_raw = other.m_raw;
    return *this;
}

Fixed::~Fixed()
{
    std::cout << "Destructor called" << std::endl;
}

int Fixed::getRawBits() const
{
    std::cout << "getRawBits member function called" << std::endl;
    return m_raw;
}

void Fixed::setRawBits(int const raw)
{
    m_raw = raw;
}
