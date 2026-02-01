/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ScalarConverter.cpp                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ScalarConverter.hpp"

ScalarConverter::ScalarConverter(void) {}
ScalarConverter::ScalarConverter(const ScalarConverter& other) { (void)other; }
ScalarConverter& ScalarConverter::operator=(const ScalarConverter& other) { (void)other; return (*this); }
ScalarConverter::~ScalarConverter(void) {}

static bool isChar(const std::string& s) { return (s.length() == 1 && !std::isdigit(s[0])); }
static bool isInt(const std::string& s) {
	size_t i = 0;
	if (s[i] == '-' || s[i] == '+') i++;
	if (i == s.length()) return false;
	for (; i < s.length(); i++) if (!std::isdigit(s[i])) return false;
	return true;
}
static bool isFloat(const std::string& s) {
	if (s == "nanf" || s == "+inff" || s == "-inff" || s == "inff") return true;
	size_t i = 0; bool hasDot = false;
	if (s[i] == '-' || s[i] == '+') i++;
	for (; i < s.length() - 1; i++) {
		if (s[i] == '.') { if (hasDot) return false; hasDot = true; }
		else if (!std::isdigit(s[i])) return false;
	}
	return (s[s.length() - 1] == 'f' && hasDot);
}
static bool isDouble(const std::string& s) {
	if (s == "nan" || s == "+inf" || s == "-inf" || s == "inf") return true;
	size_t i = 0; bool hasDot = false;
	if (s[i] == '-' || s[i] == '+') i++;
	for (; i < s.length(); i++) {
		if (s[i] == '.') { if (hasDot) return false; hasDot = true; }
		else if (!std::isdigit(s[i])) return false;
	}
	return hasDot;
}

void ScalarConverter::convert(const std::string& literal) {
	char c; int i; float f; double d;

	if (isChar(literal)) { c = literal[0]; i = static_cast<int>(c); f = static_cast<float>(c); d = static_cast<double>(c); }
	else if (isInt(literal)) { i = std::atoi(literal.c_str()); c = static_cast<char>(i); f = static_cast<float>(i); d = static_cast<double>(i); }
	else if (isFloat(literal)) { f = std::atof(literal.c_str()); c = static_cast<char>(f); i = static_cast<int>(f); d = static_cast<double>(f); }
	else if (isDouble(literal)) { d = std::atof(literal.c_str()); c = static_cast<char>(d); i = static_cast<int>(d); f = static_cast<float>(d); }
	else { std::cout << "char: impossible\nint: impossible\nfloat: impossible\ndouble: impossible" << std::endl; return; }

	if (std::isnan(d) || std::isinf(d) || d < 0 || d > 127) std::cout << "char: impossible" << std::endl;
	else if (!std::isprint(static_cast<int>(c))) std::cout << "char: Non displayable" << std::endl;
	else std::cout << "char: '" << c << "'" << std::endl;

	if (std::isnan(d) || std::isinf(d) || d < std::numeric_limits<int>::min() || d > std::numeric_limits<int>::max())
		std::cout << "int: impossible" << std::endl;
	else std::cout << "int: " << i << std::endl;

	std::cout << std::fixed << std::setprecision(1);
	std::cout << "float: " << f << "f" << std::endl;
	std::cout << "double: " << d << std::endl;
}
