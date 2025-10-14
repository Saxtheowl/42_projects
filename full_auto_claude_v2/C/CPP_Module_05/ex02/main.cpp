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
#include "AForm.hpp"
#include "ShrubberyCreationForm.hpp"
#include "RobotomyRequestForm.hpp"
#include "PresidentialPardonForm.hpp"

int main()
{
	std::cout << "=== Test 1: ShrubberyCreationForm ===" << std::endl;
	try
	{
		Bureaucrat bob("Bob", 137);
		ShrubberyCreationForm form("home");

		std::cout << bob << std::endl;
		std::cout << form << std::endl;

		bob.signForm(form);
		bob.executeForm(form);
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 2: RobotomyRequestForm ===" << std::endl;
	try
	{
		Bureaucrat alice("Alice", 45);
		RobotomyRequestForm form("Bender");

		std::cout << alice << std::endl;
		std::cout << form << std::endl;

		alice.signForm(form);
		alice.executeForm(form);
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 3: PresidentialPardonForm ===" << std::endl;
	try
	{
		Bureaucrat charlie("Charlie", 5);
		PresidentialPardonForm form("Arthur Dent");

		std::cout << charlie << std::endl;
		std::cout << form << std::endl;

		charlie.signForm(form);
		charlie.executeForm(form);
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 4: Execute unsigned form ===" << std::endl;
	try
	{
		Bureaucrat dave("Dave", 1);
		ShrubberyCreationForm form("test");

		std::cout << dave << std::endl;
		std::cout << form << std::endl;

		dave.executeForm(form);  // Should fail - not signed
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 5: Execute with insufficient grade ===" << std::endl;
	try
	{
		Bureaucrat eve("Eve", 146);
		ShrubberyCreationForm form("test2");

		std::cout << eve << std::endl;
		std::cout << form << std::endl;

		Bureaucrat signer("Signer", 1);
		signer.signForm(form);

		eve.executeForm(form);  // Should fail - grade too low
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	std::cout << "\n=== Test 6: Multiple robotomy attempts ===" << std::endl;
	try
	{
		Bureaucrat frank("Frank", 1);
		RobotomyRequestForm form1("Target1");
		RobotomyRequestForm form2("Target2");
		RobotomyRequestForm form3("Target3");

		frank.signForm(form1);
		frank.signForm(form2);
		frank.signForm(form3);

		frank.executeForm(form1);
		frank.executeForm(form2);
		frank.executeForm(form3);
	}
	catch (std::exception& e)
	{
		std::cout << "Exception caught: " << e.what() << std::endl;
	}

	return (0);
}
