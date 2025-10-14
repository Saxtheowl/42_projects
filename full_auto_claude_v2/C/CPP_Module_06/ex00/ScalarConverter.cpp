/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ScalarConverter.cpp                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ScalarConverter.hpp"

ScalarConverter::ScalarConverter() {}
ScalarConverter::ScalarConverter(const ScalarConverter& other) { (void)other; }
ScalarConverter& ScalarConverter::operator=(const ScalarConverter& other) { (void)other; return (*this); }
ScalarConverter::~ScalarConverter() {}

static bool isChar(const std::string& literal)
{
	return (literal.length() == 3 && literal[0] == '\'' && literal[2] == '\'');
}

static bool isInt(const std::string& literal)
{
	size_t i = 0;
	if (literal[i] == '+' || literal[i] == '-')
		i++;
	if (i >= literal.length())
		return (false);
	while (i < literal.length())
	{
		if (!isdigit(literal[i]))
			return (false);
		i++;
	}
	return (true);
}

static bool isFloat(const std::string& literal)
{
	if (literal == "-inff" || literal == "+inff" || literal == "nanf")
		return (true);
	if (literal[literal.length() - 1] != 'f')
		return (false);
	size_t i = 0;
	bool hasDot = false;
	if (literal[i] == '+' || literal[i] == '-')
		i++;
	if (i >= literal.length() - 1)
		return (false);
	while (i < literal.length() - 1)
	{
		if (literal[i] == '.')
		{
			if (hasDot)
				return (false);
			hasDot = true;
		}
		else if (!isdigit(literal[i]))
			return (false);
		i++;
	}
	return (hasDot);
}

static bool isDouble(const std::string& literal)
{
	if (literal == "-inf" || literal == "+inf" || literal == "nan")
		return (true);
	size_t i = 0;
	bool hasDot = false;
	if (literal[i] == '+' || literal[i] == '-')
		i++;
	if (i >= literal.length())
		return (false);
	while (i < literal.length())
	{
		if (literal[i] == '.')
		{
			if (hasDot)
				return (false);
			hasDot = true;
		}
		else if (!isdigit(literal[i]))
			return (false);
		i++;
	}
	return (hasDot);
}

static void printChar(double value)
{
	std::cout << "char: ";
	if (std::isnan(value) || std::isinf(value))
		std::cout << "impossible" << std::endl;
	else if (value < 0 || value > 127)
		std::cout << "impossible" << std::endl;
	else if (value < 32 || value == 127)
		std::cout << "Non displayable" << std::endl;
	else
		std::cout << "'" << static_cast<char>(value) << "'" << std::endl;
}

static void printInt(double value)
{
	std::cout << "int: ";
	if (std::isnan(value) || std::isinf(value))
		std::cout << "impossible" << std::endl;
	else if (value < std::numeric_limits<int>::min() || value > std::numeric_limits<int>::max())
		std::cout << "impossible" << std::endl;
	else
		std::cout << static_cast<int>(value) << std::endl;
}

static void printFloat(double value)
{
	std::cout << "float: ";
	float f = static_cast<float>(value);
	if (std::isnan(value))
		std::cout << "nanf" << std::endl;
	else if (std::isinf(value))
		std::cout << (value > 0 ? "+inff" : "-inff") << std::endl;
	else
	{
		std::cout << std::fixed << std::setprecision(1) << f << "f" << std::endl;
	}
}

static void printDouble(double value)
{
	std::cout << "double: ";
	if (std::isnan(value))
		std::cout << "nan" << std::endl;
	else if (std::isinf(value))
		std::cout << (value > 0 ? "+inf" : "-inf") << std::endl;
	else
		std::cout << std::fixed << std::setprecision(1) << value << std::endl;
}

void ScalarConverter::convert(const std::string& literal)
{
	double value = 0.0;

	if (isChar(literal))
	{
		value = static_cast<double>(literal[1]);
	}
	else if (isInt(literal))
	{
		value = static_cast<double>(std::atoi(literal.c_str()));
	}
	else if (isFloat(literal))
	{
		if (literal == "nanf")
			value = std::numeric_limits<double>::quiet_NaN();
		else if (literal == "+inff")
			value = std::numeric_limits<double>::infinity();
		else if (literal == "-inff")
			value = -std::numeric_limits<double>::infinity();
		else
			value = static_cast<double>(std::atof(literal.c_str()));
	}
	else if (isDouble(literal))
	{
		if (literal == "nan")
			value = std::numeric_limits<double>::quiet_NaN();
		else if (literal == "+inf")
			value = std::numeric_limits<double>::infinity();
		else if (literal == "-inf")
			value = -std::numeric_limits<double>::infinity();
		else
			value = std::atof(literal.c_str());
	}
	else
	{
		std::cout << "Error: Invalid literal" << std::endl;
		return;
	}

	printChar(value);
	printInt(value);
	printFloat(value);
	printDouble(value);
}
