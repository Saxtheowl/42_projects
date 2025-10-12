#ifndef COMPUTOR_HPP
#define COMPUTOR_HPP

#include <map>
#include <string>

struct Polynomial
{
    std::map<int, double> coefficients;
    int                   maxExponent;
};

Polynomial parseEquation(const std::string &input);
void       printReducedForm(const Polynomial &poly);
void       solveEquation(const Polynomial &poly);

#endif
