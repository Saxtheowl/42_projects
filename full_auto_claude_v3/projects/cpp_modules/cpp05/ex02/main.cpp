/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Bureaucrat.hpp"
#include "ShrubberyCreationForm.hpp"
#include "RobotomyRequestForm.hpp"
#include "PresidentialPardonForm.hpp"

int	main(void)
{
	std::srand(std::time(NULL));

	Bureaucrat	president("President", 1);
	Bureaucrat	intern("Intern", 150);

	ShrubberyCreationForm	shrub("home");
	RobotomyRequestForm		robot("Bender");
	PresidentialPardonForm	pardon("Arthur");

	std::cout << "=== Trying to execute unsigned forms ===" << std::endl;
	president.executeForm(shrub);

	std::cout << "\n=== Signing and executing forms ===" << std::endl;
	president.signForm(shrub);
	president.executeForm(shrub);

	std::cout << std::endl;
	president.signForm(robot);
	president.executeForm(robot);

	std::cout << std::endl;
	president.signForm(pardon);
	president.executeForm(pardon);

	std::cout << "\n=== Intern trying to execute ===" << std::endl;
	intern.executeForm(shrub);

	return (0);
}
