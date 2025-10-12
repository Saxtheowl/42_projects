#include "Complex.hpp"

#include <cmath>
#include <sstream>

Complex::Complex() : real(0.0), imag(0.0) {}
Complex::Complex(double r, double i) : real(r), imag(i) {}

Complex Complex::operator+(const Complex &other) const
{
    return Complex(real + other.real, imag + other.imag);
}

Complex Complex::operator-(const Complex &other) const
{
    return Complex(real - other.real, imag - other.imag);
}

Complex Complex::operator*(const Complex &other) const
{
    return Complex(real * other.real - imag * other.imag,
                   real * other.imag + imag * other.real);
}

Complex Complex::operator/(const Complex &other) const
{
    double denom = other.real * other.real + other.imag * other.imag;
    return Complex((real * other.real + imag * other.imag) / denom,
                   (imag * other.real - real * other.imag) / denom);
}

Complex &Complex::operator+=(const Complex &other)
{
    real += other.real;
    imag += other.imag;
    return *this;
}

Complex &Complex::operator-=(const Complex &other)
{
    real -= other.real;
    imag -= other.imag;
    return *this;
}

Complex &Complex::operator*=(const Complex &other)
{
    double r = real * other.real - imag * other.imag;
    double i = real * other.imag + imag * other.real;
    real = r;
    imag = i;
    return *this;
}

Complex &Complex::operator/=(const Complex &other)
{
    double denom = other.real * other.real + other.imag * other.imag;
    double r = (real * other.real + imag * other.imag) / denom;
    double i = (imag * other.real - real * other.imag) / denom;
    real = r;
    imag = i;
    return *this;
}

std::string Complex::toString(int precision) const
{
    std::ostringstream oss;
    oss.setf(std::ios::fixed);
    oss.precision(precision);
    if (std::fabs(imag) < 1e-9)
    {
        oss << real;
    }
    else if (std::fabs(real) < 1e-9)
    {
        oss << imag << "i";
    }
    else
    {
        oss << real;
        if (imag >= 0)
            oss << " + " << imag << "i";
        else
            oss << " - " << -imag << "i";
    }
    return oss.str();
}

static Complex fromPolar(double r, double theta)
{
    return Complex(r * std::cos(theta), r * std::sin(theta));
}

Complex sin(const Complex &z)
{
    double a = z.real;
    double b = z.imag;
    return Complex(std::sin(a) * std::cosh(b), std::cos(a) * std::sinh(b));
}

Complex cos(const Complex &z)
{
    double a = z.real;
    double b = z.imag;
    return Complex(std::cos(a) * std::cosh(b), -std::sin(a) * std::sinh(b));
}

Complex tan(const Complex &z)
{
    return sin(z) / cos(z);
}

Complex exp(const Complex &z)
{
    double expa = std::exp(z.real);
    return Complex(expa * std::cos(z.imag), expa * std::sin(z.imag));
}

Complex log(const Complex &z)
{
    double magnitude = std::sqrt(z.real * z.real + z.imag * z.imag);
    double angle = std::atan2(z.imag, z.real);
    return Complex(std::log(magnitude), angle);
}

Complex sqrt(const Complex &z)
{
    double magnitude = std::sqrt(std::sqrt(z.real * z.real + z.imag * z.imag));
    double angle = std::atan2(z.imag, z.real) / 2.0;
    return fromPolar(magnitude, angle);
}
