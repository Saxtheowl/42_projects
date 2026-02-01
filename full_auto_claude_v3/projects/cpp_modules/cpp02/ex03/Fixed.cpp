/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Fixed.cpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Fixed.hpp"

Fixed::Fixed(void) : _value(0) {}

Fixed::Fixed(const int n) { this->_value = n << _fractionalBits; }

Fixed::Fixed(const float n) { this->_value = roundf(n * (1 << _fractionalBits)); }

Fixed::Fixed(const Fixed& other) { *this = other; }

Fixed& Fixed::operator=(const Fixed& other) {
	if (this != &other) this->_value = other.getRawBits();
	return (*this);
}

Fixed::~Fixed(void) {}

int Fixed::getRawBits(void) const { return (this->_value); }

void Fixed::setRawBits(int const raw) { this->_value = raw; }

float Fixed::toFloat(void) const { return ((float)this->_value / (1 << _fractionalBits)); }

int Fixed::toInt(void) const { return (this->_value >> _fractionalBits); }

bool Fixed::operator>(const Fixed& other) const { return (this->_value > other._value); }
bool Fixed::operator<(const Fixed& other) const { return (this->_value < other._value); }
bool Fixed::operator>=(const Fixed& other) const { return (this->_value >= other._value); }
bool Fixed::operator<=(const Fixed& other) const { return (this->_value <= other._value); }
bool Fixed::operator==(const Fixed& other) const { return (this->_value == other._value); }
bool Fixed::operator!=(const Fixed& other) const { return (this->_value != other._value); }

Fixed Fixed::operator+(const Fixed& other) const {
	Fixed result; result.setRawBits(this->_value + other._value); return (result);
}

Fixed Fixed::operator-(const Fixed& other) const {
	Fixed result; result.setRawBits(this->_value - other._value); return (result);
}

Fixed Fixed::operator*(const Fixed& other) const {
	Fixed result; result.setRawBits((this->_value * other._value) >> _fractionalBits); return (result);
}

Fixed Fixed::operator/(const Fixed& other) const {
	Fixed result; result.setRawBits((this->_value << _fractionalBits) / other._value); return (result);
}

Fixed& Fixed::operator++(void) { this->_value++; return (*this); }
Fixed Fixed::operator++(int) { Fixed tmp(*this); this->_value++; return (tmp); }
Fixed& Fixed::operator--(void) { this->_value--; return (*this); }
Fixed Fixed::operator--(int) { Fixed tmp(*this); this->_value--; return (tmp); }

Fixed& Fixed::min(Fixed& a, Fixed& b) { return (a < b ? a : b); }
const Fixed& Fixed::min(const Fixed& a, const Fixed& b) { return (a < b ? a : b); }
Fixed& Fixed::max(Fixed& a, Fixed& b) { return (a > b ? a : b); }
const Fixed& Fixed::max(const Fixed& a, const Fixed& b) { return (a > b ? a : b); }

std::ostream& operator<<(std::ostream& os, const Fixed& fixed) {
	os << fixed.toFloat(); return (os);
}
