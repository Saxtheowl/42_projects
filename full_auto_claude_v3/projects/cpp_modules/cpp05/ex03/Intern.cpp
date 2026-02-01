/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Intern.cpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Intern.hpp"
#include "ShrubberyCreationForm.hpp"
#include "RobotomyRequestForm.hpp"
#include "PresidentialPardonForm.hpp"

Intern::Intern(void) {}
Intern::Intern(const Intern& other) { (void)other; }
Intern& Intern::operator=(const Intern& other) { (void)other; return (*this); }
Intern::~Intern(void) {}

static AForm* makeShrubbery(const std::string& target) { return (new ShrubberyCreationForm(target)); }
static AForm* makeRobotomy(const std::string& target) { return (new RobotomyRequestForm(target)); }
static AForm* makePardon(const std::string& target) { return (new PresidentialPardonForm(target)); }

AForm* Intern::makeForm(const std::string& name, const std::string& target) {
	std::string	names[3] = {"shrubbery creation", "robotomy request", "presidential pardon"};
	AForm*		(*funcs[3])(const std::string&) = {&makeShrubbery, &makeRobotomy, &makePardon};

	for (int i = 0; i < 3; i++) {
		if (names[i] == name) {
			std::cout << "Intern creates " << name << std::endl;
			return (funcs[i](target));
		}
	}
	std::cout << "Intern cannot create unknown form: " << name << std::endl;
	return (NULL);
}
