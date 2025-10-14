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

int main()
{
	std::cout << "=== Test 1: Valid bureaucrats ===" << std::endl;
	try
	{
		Bureaucrat bob("Bob", 1);
		std::cout << bob << std::endl;

		Bureaucrat alice("Alice", 75);
		std::cout << alice << std::endl;

		Bureaucrat charlie("Charlie", 150);
		std::cout << charlie << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 2: Grade too high (0) ===" << std::endl;
	try
	{
		Bureaucrat invalid("Invalid", 0);
		std::cout << invalid << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 3: Grade too low (151) ===" << std::endl;
	try
	{
		Bureaucrat invalid("Invalid", 151);
		std::cout << invalid << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 4: Increment grade ===" << std::endl;
	try
	{
		Bureaucrat dave("Dave", 3);
		std::cout << dave << std::endl;

		dave.incrementGrade();
		std::cout << "After increment: " << dave << std::endl;

		dave.incrementGrade();
		std::cout << "After increment: " << dave << std::endl;

		dave.incrementGrade();  // Should throw exception (can't go below 1)
		std::cout << "After increment: " << dave << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 5: Decrement grade ===" << std::endl;
	try
	{
		Bureaucrat eve("Eve", 148);
		std::cout << eve << std::endl;

		eve.decrementGrade();
		std::cout << "After decrement: " << eve << std::endl;

		eve.decrementGrade();
		std::cout << "After decrement: " << eve << std::endl;

		eve.decrementGrade();  // Should throw exception (can't go above 150)
		std::cout << "After decrement: " << eve << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 6: Copy constructor and assignment ===" << std::endl;
	try
	{
		Bureaucrat original("Original", 42);
		std::cout << "Original: " << original << std::endl;

		Bureaucrat copy(original);
		std::cout << "Copy: " << copy << std::endl;

		Bureaucrat assigned("Assigned", 100);
		std::cout << "Before assignment: " << assigned << std::endl;
		assigned = original;
		std::cout << "After assignment: " << assigned << std::endl;
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	return (0);
}
