#pragma once

#include <iostream>

class Fixed
{
public:
	Fixed();
	Fixed(const int value);
	Fixed(const float value);
	Fixed(const Fixed &other);
	Fixed &operator=(const Fixed &other);
	~Fixed();

	int getRawBits() const;
	float toFloat() const;

	bool operator>(const Fixed &rhs) const;
	bool operator<(const Fixed &rhs) const;
	Fixed operator-(const Fixed &rhs) const;
	Fixed operator+(const Fixed &rhs) const;
	Fixed operator*(const Fixed &rhs) const;

private:
	int _value;
	static const int _fractionalBits = 8;
};

std::ostream &operator<<(std::ostream &os, const Fixed &fixed);
