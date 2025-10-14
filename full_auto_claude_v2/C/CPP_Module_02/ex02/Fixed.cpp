/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Fixed.cpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Fixed.hpp"
#include <cmath>

Fixed::Fixed() : value(0)
{
}

Fixed::Fixed(const int n)
{
	this->value = n << this->fractionalBits;
}

Fixed::Fixed(const float f)
{
	this->value = roundf(f * (1 << this->fractionalBits));
}

Fixed::Fixed(const Fixed& other)
{
	*this = other;
}

Fixed& Fixed::operator=(const Fixed& other)
{
	if (this != &other)
	{
		this->value = other.getRawBits();
	}
	return (*this);
}

Fixed::~Fixed()
{
}

int	Fixed::getRawBits(void) const
{
	return (this->value);
}

void	Fixed::setRawBits(int const raw)
{
	this->value = raw;
}

float	Fixed::toFloat(void) const
{
	return (static_cast<float>(this->value) / (1 << this->fractionalBits));
}

int	Fixed::toInt(void) const
{
	return (this->value >> this->fractionalBits);
}

// Comparison operators
bool	Fixed::operator>(const Fixed& other) const
{
	return (this->value > other.value);
}

bool	Fixed::operator<(const Fixed& other) const
{
	return (this->value < other.value);
}

bool	Fixed::operator>=(const Fixed& other) const
{
	return (this->value >= other.value);
}

bool	Fixed::operator<=(const Fixed& other) const
{
	return (this->value <= other.value);
}

bool	Fixed::operator==(const Fixed& other) const
{
	return (this->value == other.value);
}

bool	Fixed::operator!=(const Fixed& other) const
{
	return (this->value != other.value);
}

// Arithmetic operators
Fixed	Fixed::operator+(const Fixed& other) const
{
	Fixed	result;
	result.setRawBits(this->value + other.value);
	return (result);
}

Fixed	Fixed::operator-(const Fixed& other) const
{
	Fixed	result;
	result.setRawBits(this->value - other.value);
	return (result);
}

Fixed	Fixed::operator*(const Fixed& other) const
{
	Fixed	result;
	result.setRawBits((this->value * other.value) >> this->fractionalBits);
	return (result);
}

Fixed	Fixed::operator/(const Fixed& other) const
{
	Fixed	result;
	result.setRawBits((this->value << this->fractionalBits) / other.value);
	return (result);
}

// Increment/Decrement operators
Fixed&	Fixed::operator++(void)
{
	this->value++;
	return (*this);
}

Fixed	Fixed::operator++(int)
{
	Fixed	temp(*this);
	this->value++;
	return (temp);
}

Fixed&	Fixed::operator--(void)
{
	this->value--;
	return (*this);
}

Fixed	Fixed::operator--(int)
{
	Fixed	temp(*this);
	this->value--;
	return (temp);
}

// Static member functions
Fixed&	Fixed::min(Fixed& a, Fixed& b)
{
	return (a < b ? a : b);
}

const Fixed&	Fixed::min(const Fixed& a, const Fixed& b)
{
	return (a < b ? a : b);
}

Fixed&	Fixed::max(Fixed& a, Fixed& b)
{
	return (a > b ? a : b);
}

const Fixed&	Fixed::max(const Fixed& a, const Fixed& b)
{
	return (a > b ? a : b);
}

std::ostream&	operator<<(std::ostream& out, const Fixed& fixed)
{
	out << fixed.toFloat();
	return (out);
}
