#include "ScalarConverter.hpp"

#include <cctype>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <limits>

ScalarConverter::ScalarConverter() {}
ScalarConverter::ScalarConverter(const ScalarConverter &) {}
ScalarConverter &ScalarConverter::operator=(const ScalarConverter &)
{
    return *this;
}
ScalarConverter::~ScalarConverter() {}

namespace
{
    bool isPseudoFloat(const std::string &literal)
    {
        return literal == "nanf" || literal == "+inff" || literal == "-inff";
    }

    bool isPseudoDouble(const std::string &literal)
    {
        return literal == "nan" || literal == "+inf" || literal == "-inf";
    }

    bool isInt(const std::string &literal)
    {
        char *end = 0;
        long value = std::strtol(literal.c_str(), &end, 10);
        if (*end != '\0')
            return false;
        return value >= std::numeric_limits<int>::min() && value <= std::numeric_limits<int>::max();
    }

    bool isFloat(const std::string &literal)
    {
        if (literal.size() < 2 || literal[literal.size() - 1] != 'f')
            return false;
        char *end = 0;
        std::strtod(literal.c_str(), &end);
        return end == literal.c_str() + literal.size() - 1;
    }

    bool isDouble(const std::string &literal)
    {
        char *end = 0;
        std::strtod(literal.c_str(), &end);
        return *end == '\0';
    }
}

void ScalarConverter::convert(const std::string &literal)
{
    std::cout << std::fixed << std::setprecision(1);

    if (literal.length() == 1 && !std::isdigit(static_cast<unsigned char>(literal[0])))
    {
        char c = literal[0];
        std::cout << "char: '" << c << "'" << std::endl;
        std::cout << "int: " << static_cast<int>(c) << std::endl;
        std::cout << "float: " << static_cast<float>(c) << "f" << std::endl;
        std::cout << "double: " << static_cast<double>(c) << std::endl;
        return;
    }

    if (isPseudoFloat(literal) || isPseudoDouble(literal))
    {
        std::cout << "char: impossible" << std::endl;
        std::cout << "int: impossible" << std::endl;
        if (isPseudoFloat(literal))
        {
            std::cout << "float: " << literal << std::endl;
            std::cout << "double: " << literal.substr(0, literal.size() - 1) << std::endl;
        }
        else
        {
            std::cout << "float: " << literal << "f" << std::endl;
            std::cout << "double: " << literal << std::endl;
        }
        return;
    }

    if (isInt(literal))
    {
        int value = std::atoi(literal.c_str());
        if (value >= std::numeric_limits<char>::min() && value <= std::numeric_limits<char>::max())
        {
            char c = static_cast<char>(value);
            if (std::isprint(static_cast<unsigned char>(c)))
                std::cout << "char: '" << c << "'" << std::endl;
            else
                std::cout << "char: Non displayable" << std::endl;
        }
        else
        {
            std::cout << "char: impossible" << std::endl;
        }
        std::cout << "int: " << value << std::endl;
        std::cout << "float: " << static_cast<float>(value) << "f" << std::endl;
        std::cout << "double: " << static_cast<double>(value) << std::endl;
        return;
    }

    if (isFloat(literal))
    {
        float value = static_cast<float>(std::atof(literal.c_str()));
        if (value >= std::numeric_limits<char>::min() && value <= std::numeric_limits<char>::max())
        {
            char c = static_cast<char>(value);
            if (std::isprint(static_cast<unsigned char>(c)))
                std::cout << "char: '" << c << "'" << std::endl;
            else
                std::cout << "char: Non displayable" << std::endl;
        }
        else
        {
            std::cout << "char: impossible" << std::endl;
        }
        if (value >= std::numeric_limits<int>::min() && value <= std::numeric_limits<int>::max())
            std::cout << "int: " << static_cast<int>(value) << std::endl;
        else
            std::cout << "int: impossible" << std::endl;
        std::cout << "float: " << value << "f" << std::endl;
        std::cout << "double: " << static_cast<double>(value) << std::endl;
        return;
    }

    if (isDouble(literal))
    {
        double value = std::atof(literal.c_str());
        if (value >= std::numeric_limits<char>::min() && value <= std::numeric_limits<char>::max())
        {
            char c = static_cast<char>(value);
            if (std::isprint(static_cast<unsigned char>(c)))
                std::cout << "char: '" << c << "'" << std::endl;
            else
                std::cout << "char: Non displayable" << std::endl;
        }
        else
        {
            std::cout << "char: impossible" << std::endl;
        }
        if (value >= std::numeric_limits<int>::min() && value <= std::numeric_limits<int>::max())
            std::cout << "int: " << static_cast<int>(value) << std::endl;
        else
            std::cout << "int: impossible" << std::endl;
        if (value >= -std::numeric_limits<float>::max() && value <= std::numeric_limits<float>::max())
            std::cout << "float: " << static_cast<float>(value) << "f" << std::endl;
        else
            std::cout << "float: impossible" << std::endl;
        std::cout << "double: " << value << std::endl;
        return;
    }

    std::cout << "char: impossible" << std::endl;
    std::cout << "int: impossible" << std::endl;
    std::cout << "float: impossible" << std::endl;
    std::cout << "double: impossible" << std::endl;
}
