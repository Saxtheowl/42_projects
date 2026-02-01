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
#include "Intern.hpp"

int	main(void)
{
	Intern		intern;
	Bureaucrat	boss("Boss", 1);

	AForm*	form1 = intern.makeForm("shrubbery creation", "garden");
	AForm*	form2 = intern.makeForm("robotomy request", "Bender");
	AForm*	form3 = intern.makeForm("presidential pardon", "Ford");
	AForm*	form4 = intern.makeForm("unknown form", "target");

	if (form1) { boss.signForm(*form1); boss.executeForm(*form1); delete form1; }
	if (form2) { boss.signForm(*form2); boss.executeForm(*form2); delete form2; }
	if (form3) { boss.signForm(*form3); boss.executeForm(*form3); delete form3; }
	if (form4) { delete form4; }

	return (0);
}
