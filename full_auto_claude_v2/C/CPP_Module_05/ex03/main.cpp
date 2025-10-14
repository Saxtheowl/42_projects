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
#include "Intern.hpp"

int main()
{
	Intern	someRandomIntern;
	Bureaucrat	boss("Boss", 1);

	std::cout << "=== Test 1: Create shrubbery creation form ===" << std::endl;
	AForm* form1 = someRandomIntern.makeForm("shrubbery creation", "garden");
	if (form1)
	{
		std::cout << *form1 << std::endl;
		boss.signForm(*form1);
		boss.executeForm(*form1);
		delete form1;
	}

	std::cout << "\n=== Test 2: Create robotomy request form ===" << std::endl;
	AForm* form2 = someRandomIntern.makeForm("robotomy request", "Bender");
	if (form2)
	{
		std::cout << *form2 << std::endl;
		boss.signForm(*form2);
		boss.executeForm(*form2);
		delete form2;
	}

	std::cout << "\n=== Test 3: Create presidential pardon form ===" << std::endl;
	AForm* form3 = someRandomIntern.makeForm("presidential pardon", "Arthur Dent");
	if (form3)
	{
		std::cout << *form3 << std::endl;
		boss.signForm(*form3);
		boss.executeForm(*form3);
		delete form3;
	}

	std::cout << "\n=== Test 4: Try to create unknown form ===" << std::endl;
	AForm* form4 = someRandomIntern.makeForm("unknown form", "target");
	if (form4)
	{
		std::cout << *form4 << std::endl;
		delete form4;
	}
	else
	{
		std::cout << "Form creation failed (NULL returned)" << std::endl;
	}

	std::cout << "\n=== Test 5: Create multiple forms ===" << std::endl;
	Intern anotherIntern;
	AForm* forms[3];

	forms[0] = anotherIntern.makeForm("shrubbery creation", "office");
	forms[1] = anotherIntern.makeForm("robotomy request", "Employee");
	forms[2] = anotherIntern.makeForm("presidential pardon", "Criminal");

	for (int i = 0; i < 3; i++)
	{
		if (forms[i])
		{
			std::cout << *forms[i] << std::endl;
			boss.signForm(*forms[i]);
			boss.executeForm(*forms[i]);
			delete forms[i];
		}
	}

	return (0);
}
