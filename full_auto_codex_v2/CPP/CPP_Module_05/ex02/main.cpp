#include "AForm.hpp"
#include "Bureaucrat.hpp"
#include "PresidentialPardonForm.hpp"
#include "RobotomyRequestForm.hpp"
#include "ShrubberyCreationForm.hpp"

#include <iostream>

int main()
{
	Bureaucrat high("Arthur", 1);
	Bureaucrat low("Tim", 150);

	ShrubberyCreationForm tree("garden");
	RobotomyRequestForm robot("Marvin");
	PresidentialPardonForm pardon("Ford");

	low.signForm(tree);
	high.signForm(tree);
	high.executeForm(tree);

	high.signForm(robot);
	for (int i = 0; i < 4; ++i)
		high.executeForm(robot);

	high.signForm(pardon);
	high.executeForm(pardon);

	try
	{
		low.executeForm(pardon);
	}
	catch (std::exception &e)
	{
		std::cout << "Manual catch: " << e.what() << std::endl;
	}
	return 0;
}
