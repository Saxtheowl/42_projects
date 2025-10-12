#include "Computor.hpp"

#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <iostream>

namespace
{
    const double EPS = 1e-9;

    double parseCoefficient(const std::string &str, size_t &pos)
    {
        char *end = 0;
        double value = std::strtod(str.c_str() + pos, &end);
        if (end == str.c_str() + pos)
            throw std::runtime_error("Invalid coefficient in expression");
        pos = static_cast<size_t>(end - str.c_str());
        return value;
    }

    long parseExponent(const std::string &str, size_t &pos)
    {
        char *end = 0;
        long value = std::strtol(str.c_str() + pos, &end, 10);
        if (end == str.c_str() + pos)
            throw std::runtime_error("Invalid exponent in expression");
        pos = static_cast<size_t>(end - str.c_str());
        return value;
    }

    void accumulateTerm(Polynomial &poly, int exponent, double value, bool subtract)
    {
        if (subtract)
            value = -value;
        poly.coefficients[exponent] += value;
        if (poly.maxExponent < exponent)
            poly.maxExponent = exponent;
    }
}

Polynomial parseEquation(const std::string &input)
{
    Polynomial poly;
    poly.maxExponent = 0;

    std::string cleaned;
    cleaned.reserve(input.size());
    for (size_t i = 0; i < input.size(); ++i)
    {
        char c = input[i];
        if (c != ' ')
        {
            if (c >= 'a' && c <= 'z')
                c = static_cast<char>(c - 'a' + 'A');
            cleaned += c;
        }
    }

    size_t equalPos = cleaned.find('=');
    if (equalPos == std::string::npos)
        throw std::runtime_error("Equation must contain '=' sign");

    std::string left = cleaned.substr(0, equalPos);
    std::string right = cleaned.substr(equalPos + 1);

    for (int side = 0; side < 2; ++side)
    {
        const std::string &part = (side == 0) ? left : right;
        bool subtract = (side == 1);
        size_t pos = 0;
        while (pos < part.size())
        {
            int sign = 1;
            if (part[pos] == '+')
            {
                ++pos;
            }
            else if (part[pos] == '-')
            {
                sign = -1;
                ++pos;
            }
            if (pos >= part.size())
                throw std::runtime_error("Unexpected end of expression");

            double coeff = parseCoefficient(part, pos);
            coeff *= sign;

            if (pos >= part.size() || part[pos] != '*')
                throw std::runtime_error("Expected '*' after coefficient");
            ++pos;
            if (pos >= part.size() || part[pos] != 'X')
                throw std::runtime_error("Expected 'X'");
            ++pos;
            if (pos >= part.size() || part[pos] != '^')
                throw std::runtime_error("Expected '^'");
            ++pos;
            long exponent = parseExponent(part, pos);
            if (exponent < 0)
                throw std::runtime_error("Negative exponents are not supported");

            accumulateTerm(poly, static_cast<int>(exponent), coeff, subtract);
        }
    }

    // Normalize near-zero coefficients to zero
    for (std::map<int, double>::iterator it = poly.coefficients.begin(); it != poly.coefficients.end(); ++it)
    {
        if (std::fabs(it->second) < EPS)
            it->second = 0.0;
    }

    return poly;
}

void printReducedForm(const Polynomial &poly)
{
    std::cout << "Reduced form: ";
    bool first = true;
    for (int exp = 0; exp <= poly.maxExponent; ++exp)
    {
        std::map<int, double>::const_iterator it = poly.coefficients.find(exp);
        double coeff = (it == poly.coefficients.end()) ? 0.0 : it->second;
        if (std::fabs(coeff) < EPS)
            coeff = 0.0;
        if (first)
        {
            std::cout << coeff << " * X^" << exp;
            first = false;
        }
        else
        {
            if (coeff < 0)
                std::cout << " - " << std::fabs(coeff) << " * X^" << exp;
            else
                std::cout << " + " << coeff << " * X^" << exp;
        }
    }
    if (first)
        std::cout << "0";
    std::cout << " = 0" << std::endl;
}

void solveEquation(const Polynomial &poly)
{
    int degree = 0;
    for (std::map<int, double>::const_reverse_iterator it = poly.coefficients.rbegin(); it != poly.coefficients.rend(); ++it)
    {
        if (std::fabs(it->second) >= EPS)
        {
            degree = it->first;
            break;
        }
    }

    std::cout << "Polynomial degree: " << degree << std::endl;
    std::cout << std::fixed << std::setprecision(6);

    if (degree > 2)
    {
        std::cout << "The polynomial degree is strictly greater than 2, I can't solve." << std::endl;
        return;
    }

    double a0 = 0.0;
    double a1 = 0.0;
    double a2 = 0.0;
    std::map<int, double>::const_iterator it0 = poly.coefficients.find(0);
    if (it0 != poly.coefficients.end())
        a0 = it0->second;
    std::map<int, double>::const_iterator it1 = poly.coefficients.find(1);
    if (it1 != poly.coefficients.end())
        a1 = it1->second;
    std::map<int, double>::const_iterator it2 = poly.coefficients.find(2);
    if (it2 != poly.coefficients.end())
        a2 = it2->second;

    if (degree == 0)
    {
        if (std::fabs(a0) < EPS)
            std::cout << "All real numbers are solution." << std::endl;
        else
            std::cout << "No solution." << std::endl;
        return;
    }

    if (degree == 1)
    {
        double solution = -a0 / a1;
        std::cout << "The solution is:" << std::endl;
        std::cout << solution << std::endl;
        return;
    }

    double discriminant = a1 * a1 - 4.0 * a2 * a0;
    if (discriminant > EPS)
    {
        std::cout << "Discriminant is strictly positive, the two solutions are:" << std::endl;
        double sqrtDisc = std::sqrt(discriminant);
        double x1 = (-a1 + sqrtDisc) / (2.0 * a2);
        double x2 = (-a1 - sqrtDisc) / (2.0 * a2);
        std::cout << x1 << std::endl;
        std::cout << x2 << std::endl;
    }
    else if (std::fabs(discriminant) <= EPS)
    {
        std::cout << "Discriminant equals zero, the solution is:" << std::endl;
        double x = -a1 / (2.0 * a2);
        std::cout << x << std::endl;
    }
    else
    {
        std::cout << "Discriminant is strictly negative, the two complex solutions are:" << std::endl;
        double sqrtDisc = std::sqrt(-discriminant);
        double real = -a1 / (2.0 * a2);
        double imag = sqrtDisc / (2.0 * a2);
        std::cout << real << " + " << imag << "i" << std::endl;
        std::cout << real << " - " << imag << "i" << std::endl;
    }
}
