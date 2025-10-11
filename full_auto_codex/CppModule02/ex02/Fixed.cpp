#include "Fixed.hpp"

#include <cmath>
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

Fixed::Fixed(int value)
    : m_raw(value << s_fractionalBits)
{
    std::cout << "Int constructor called" << std::endl;
}

Fixed::Fixed(float value)
    : m_raw(static_cast<int>(::roundf(value * (1 << s_fractionalBits))))
{
    std::cout << "Float constructor called" << std::endl;
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

float Fixed::toFloat() const
{
    return static_cast<float>(m_raw) / static_cast<float>(1 << s_fractionalBits);
}

int Fixed::toInt() const
{
    return m_raw >> s_fractionalBits;
}

bool Fixed::operator>(const Fixed &other) const
{
    return m_raw > other.m_raw;
}

bool Fixed::operator<(const Fixed &other) const
{
    return m_raw < other.m_raw;
}

bool Fixed::operator>=(const Fixed &other) const
{
    return m_raw >= other.m_raw;
}

bool Fixed::operator<=(const Fixed &other) const
{
    return m_raw <= other.m_raw;
}

bool Fixed::operator==(const Fixed &other) const
{
    return m_raw == other.m_raw;
}

bool Fixed::operator!=(const Fixed &other) const
{
    return m_raw != other.m_raw;
}

Fixed Fixed::operator+(const Fixed &other) const
{
    return Fixed(this->toFloat() + other.toFloat());
}

Fixed Fixed::operator-(const Fixed &other) const
{
    return Fixed(this->toFloat() - other.toFloat());
}

Fixed Fixed::operator*(const Fixed &other) const
{
    return Fixed(this->toFloat() * other.toFloat());
}

Fixed Fixed::operator/(const Fixed &other) const
{
    if (other.m_raw == 0)
    {
        std::cerr << "Warning: division by zero" << std::endl;
        return Fixed(0);
    }
    return Fixed(this->toFloat() / other.toFloat());
}

Fixed &Fixed::operator++()
{
    ++m_raw;
    return *this;
}

Fixed Fixed::operator++(int)
{
    Fixed tmp(*this);
    ++m_raw;
    return tmp;
}

Fixed &Fixed::operator--()
{
    --m_raw;
    return *this;
}

Fixed Fixed::operator--(int)
{
    Fixed tmp(*this);
    --m_raw;
    return tmp;
}

Fixed &Fixed::min(Fixed &a, Fixed &b)
{
    return (a < b) ? a : b;
}

const Fixed &Fixed::min(const Fixed &a, const Fixed &b)
{
    return (a < b) ? a : b;
}

Fixed &Fixed::max(Fixed &a, Fixed &b)
{
    return (a > b) ? a : b;
}

const Fixed &Fixed::max(const Fixed &a, const Fixed &b)
{
    return (a > b) ? a : b;
}

std::ostream &operator<<(std::ostream &os, const Fixed &value)
{
    os << value.toFloat();
    return os;
}
