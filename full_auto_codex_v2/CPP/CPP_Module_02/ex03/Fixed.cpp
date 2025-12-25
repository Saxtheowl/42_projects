#include "Fixed.hpp"

#include <cmath>

Fixed::Fixed() : _value(0) {}

Fixed::Fixed(const int value)
{
	_value = value << _fractionalBits;
}

Fixed::Fixed(const float value)
{
	_value = static_cast<int>(roundf(value * (1 << _fractionalBits)));
}

Fixed::Fixed(const Fixed &other)
{
	*this = other;
}

Fixed &Fixed::operator=(const Fixed &other)
{
	if (this != &other)
		_value = other._value;
	return *this;
}

Fixed::~Fixed() {}

int Fixed::getRawBits() const { return _value; }

float Fixed::toFloat() const { return static_cast<float>(_value) / (1 << _fractionalBits); }

bool Fixed::operator>(const Fixed &rhs) const { return _value > rhs._value; }
bool Fixed::operator<(const Fixed &rhs) const { return _value < rhs._value; }

Fixed Fixed::operator-(const Fixed &rhs) const
{
	Fixed res;
	res._value = _value - rhs._value;
	return res;
}

Fixed Fixed::operator+(const Fixed &rhs) const
{
	Fixed res;
	res._value = _value + rhs._value;
	return res;
}

Fixed Fixed::operator*(const Fixed &rhs) const
{
	Fixed res;
	long tmp = static_cast<long>(_value) * static_cast<long>(rhs._value);
	res._value = static_cast<int>(tmp >> _fractionalBits);
	return res;
}

std::ostream &operator<<(std::ostream &os, const Fixed &fixed)
{
	os << fixed.toFloat();
	return os;
}
