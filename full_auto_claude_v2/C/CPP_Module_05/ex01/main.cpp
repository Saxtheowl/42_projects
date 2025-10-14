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

#include "Bureaucrat.hpp"
#include "Form.hpp"

int main()
{
	std::cout << "=== Test 1: Valid form creation ===" << std::endl;
	try
	{
		Form form1("Tax Form", 50, 25);
		std::cout << form1 << std::endl;

		Form form2("Building Permit", 100, 50);
		std::cout << form2 << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 2: Invalid form creation (grade too high) ===" << std::endl;
	try
	{
		Form invalid("Invalid", 0, 50);
		std::cout << invalid << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 3: Invalid form creation (grade too low) ===" << std::endl;
	try
	{
		Form invalid("Invalid", 50, 151);
		std::cout << invalid << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 4: Successful form signing ===" << std::endl;
	try
	{
		Bureaucrat alice("Alice", 30);
		Form form("Budget Request", 50, 25);

		std::cout << alice << std::endl;
		std::cout << form << std::endl;

		alice.signForm(form);
		std::cout << form << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 5: Failed form signing (grade too low) ===" << std::endl;
	try
	{
		Bureaucrat bob("Bob", 100);
		Form form("Top Secret", 50, 25);

		std::cout << bob << std::endl;
		std::cout << form << std::endl;

		bob.signForm(form);
		std::cout << form << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 6: Edge case - exact grade match ===" << std::endl;
	try
	{
		Bureaucrat charlie("Charlie", 50);
		Form form("Standard Form", 50, 25);

		std::cout << charlie << std::endl;
		std::cout << form << std::endl;

		charlie.signForm(form);
		std::cout << form << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 7: Multiple signing attempts ===" << std::endl;
	try
	{
		Bureaucrat dave("Dave", 1);
		Form form("Important Document", 50, 25);

		std::cout << form << std::endl;

		dave.signForm(form);
		std::cout << form << std::endl;

		// Try signing again (already signed)
		dave.signForm(form);
		std::cout << form << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	return (0);
}
