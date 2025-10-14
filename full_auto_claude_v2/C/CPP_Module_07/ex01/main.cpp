/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "iter.hpp"
#include <iostream>
#include <string>

template<typename T>
void print(T const & x)
{
	std::cout << x << std::endl;
}

template<typename T>
void increment(T & x)
{
	x++;
}

void toUpper(char & c)
{
	if (c >= 'a' && c <= 'z')
		c = c - 32;
}

int main()
{
	std::cout << "=== Test 1: Print int array ===" << std::endl;
	int intArray[] = {1, 2, 3, 4, 5};
	::iter(intArray, 5, print<int>);

	std::cout << "\n=== Test 2: Increment int array ===" << std::endl;
	::iter(intArray, 5, increment<int>);
	::iter(intArray, 5, print<int>);

	std::cout << "\n=== Test 3: Print string array ===" << std::endl;
	std::string strArray[] = {"Hello", "World", "from", "C++", "templates"};
	::iter(strArray, 5, print<std::string>);

	std::cout << "\n=== Test 4: Print double array ===" << std::endl;
	double doubleArray[] = {1.1, 2.2, 3.3, 4.4, 5.5};
	::iter(doubleArray, 5, print<double>);

	std::cout << "\n=== Test 5: Convert char array to uppercase ===" << std::endl;
	char charArray[] = {'h', 'e', 'l', 'l', 'o'};
	std::cout << "Before: ";
	::iter(charArray, 5, print<char>);
	::iter(charArray, 5, toUpper);
	std::cout << "After: ";
	::iter(charArray, 5, print<char>);

	return (0);
}
