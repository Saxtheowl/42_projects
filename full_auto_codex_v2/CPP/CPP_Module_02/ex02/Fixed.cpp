#include "Fixed.hpp"

#include <cmath>
#include <stdexcept>

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

void Fixed::setRawBits(int const raw) { _value = raw; }

float Fixed::toFloat() const { return static_cast<float>(_value) / (1 << _fractionalBits); }

int Fixed::toInt() const { return _value >> _fractionalBits; }

bool Fixed::operator>(const Fixed &rhs) const { return _value > rhs._value; }
bool Fixed::operator<(const Fixed &rhs) const { return _value < rhs._value; }
bool Fixed::operator>=(const Fixed &rhs) const { return _value >= rhs._value; }
bool Fixed::operator<=(const Fixed &rhs) const { return _value <= rhs._value; }
bool Fixed::operator==(const Fixed &rhs) const { return _value == rhs._value; }
bool Fixed::operator!=(const Fixed &rhs) const { return _value != rhs._value; }

Fixed Fixed::operator+(const Fixed &rhs) const
{
	Fixed res;
	res._value = _value + rhs._value;
	return res;
}

Fixed Fixed::operator-(const Fixed &rhs) const
{
	Fixed res;
	res._value = _value - rhs._value;
	return res;
}

Fixed Fixed::operator*(const Fixed &rhs) const
{
	Fixed res;
	long tmp = static_cast<long>(_value) * static_cast<long>(rhs._value);
	res._value = static_cast<int>(tmp >> _fractionalBits);
	return res;
}

Fixed Fixed::operator/(const Fixed &rhs) const
{
	if (rhs._value == 0)
		throw std::runtime_error("Division by zero");
	Fixed res;
	long tmp = (static_cast<long>(_value) << _fractionalBits) / rhs._value;
	res._value = static_cast<int>(tmp);
	return res;
}

Fixed &Fixed::operator++()
{
	++_value;
	return *this;
}

Fixed Fixed::operator++(int)
{
	Fixed tmp(*this);
	++_value;
	return tmp;
}

Fixed &Fixed::operator--()
{
	--_value;
	return *this;
}

Fixed Fixed::operator--(int)
{
	Fixed tmp(*this);
	--_value;
	return tmp;
}

Fixed &Fixed::min(Fixed &a, Fixed &b) { return (a < b) ? a : b; }
const Fixed &Fixed::min(const Fixed &a, const Fixed &b) { return (a < b) ? a : b; }
Fixed &Fixed::max(Fixed &a, Fixed &b) { return (a > b) ? a : b; }
const Fixed &Fixed::max(const Fixed &a, const Fixed &b) { return (a > b) ? a : b; }

std::ostream &operator<<(std::ostream &os, const Fixed &fixed)
{
	os << fixed.toFloat();
	return os;
}
