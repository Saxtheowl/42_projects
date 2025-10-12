#ifndef COMPLEX_HPP
#define COMPLEX_HPP

#include <string>

struct Complex
{
    double real;
    double imag;

    Complex();
    Complex(double r, double i = 0.0);

    Complex operator+(const Complex &other) const;
    Complex operator-(const Complex &other) const;
    Complex operator*(const Complex &other) const;
    Complex operator/(const Complex &other) const;

    Complex &operator+=(const Complex &other);
    Complex &operator-=(const Complex &other);
    Complex &operator*=(const Complex &other);
    Complex &operator/=(const Complex &other);

    std::string toString(int precision = 6) const;
};

Complex sin(const Complex &z);
Complex cos(const Complex &z);
Complex tan(const Complex &z);
Complex exp(const Complex &z);
Complex log(const Complex &z);
Complex sqrt(const Complex &z);

#endif
