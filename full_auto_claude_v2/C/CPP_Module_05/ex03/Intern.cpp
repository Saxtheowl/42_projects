/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Intern.cpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Intern.hpp"

Intern::Intern()
{
}

Intern::Intern(const Intern& other)
{
	(void)other;
}

Intern& Intern::operator=(const Intern& other)
{
	(void)other;
	return (*this);
}

Intern::~Intern()
{
}

static AForm* createShrubberyForm(const std::string& target)
{
	return (new ShrubberyCreationForm(target));
}

static AForm* createRobotomyForm(const std::string& target)
{
	return (new RobotomyRequestForm(target));
}

static AForm* createPresidentialForm(const std::string& target)
{
	return (new PresidentialPardonForm(target));
}

AForm* Intern::makeForm(const std::string& formName, const std::string& target) const
{
	std::string formNames[3] = {
		"shrubbery creation",
		"robotomy request",
		"presidential pardon"
	};

	AForm* (*formCreators[3])(const std::string&) = {
		&createShrubberyForm,
		&createRobotomyForm,
		&createPresidentialForm
	};

	for (int i = 0; i < 3; i++)
	{
		if (formNames[i] == formName)
		{
			std::cout << "Intern creates " << formName << std::endl;
			return (formCreators[i](target));
		}
	}

	std::cout << "Error: Form name \"" << formName << "\" is not recognized" << std::endl;
	return (NULL);
}
