#include "Bureaucrat.hpp"
#include "Intern.hpp"
#include "AForm.hpp"

#include <iostream>

int main()
{
	Intern someRandomIntern;
	Bureaucrat boss("Boss", 1);
	Bureaucrat assistant("Assistant", 140);

	AForm *shrub = someRandomIntern.makeForm("shrubbery creation", "garden");
	AForm *robot = someRandomIntern.makeForm("robotomy request", "Marvin");
	AForm *pardon = someRandomIntern.makeForm("presidential pardon", "Ford");

	try
	{
		someRandomIntern.makeForm("unknown form", "nobody");
	}
	catch (std::exception &e)
	{
		std::cout << "Intern failed to create: " << e.what() << std::endl;
	}

	assistant.signForm(*shrub);
	boss.signForm(*shrub);
	boss.executeForm(*shrub);

	boss.signForm(*robot);
	for (int i = 0; i < 3; ++i)
		boss.executeForm(*robot);

	boss.signForm(*pardon);
	boss.executeForm(*pardon);

	delete shrub;
	delete robot;
	delete pardon;
	return 0;
}
