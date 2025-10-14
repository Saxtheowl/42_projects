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

#include "functions.hpp"
#include "A.hpp"
#include "B.hpp"
#include "C.hpp"
#include <iostream>

int main()
{
	std::cout << "=== Test 1: Random generation and identification ===" << std::endl;
	Base* random = generate();
	std::cout << "Identify by pointer: ";
	identify(random);
	std::cout << "Identify by reference: ";
	identify(*random);
	delete random;

	std::cout << "\n=== Test 2: Explicit A ===" << std::endl;
	Base* a = new A();
	std::cout << "Identify by pointer: ";
	identify(a);
	std::cout << "Identify by reference: ";
	identify(*a);
	delete a;

	std::cout << "\n=== Test 3: Explicit B ===" << std::endl;
	Base* b = new B();
	std::cout << "Identify by pointer: ";
	identify(b);
	std::cout << "Identify by reference: ";
	identify(*b);
	delete b;

	std::cout << "\n=== Test 4: Explicit C ===" << std::endl;
	Base* c = new C();
	std::cout << "Identify by pointer: ";
	identify(c);
	std::cout << "Identify by reference: ";
	identify(*c);
	delete c;

	return (0);
}
