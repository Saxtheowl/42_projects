#include "Bureaucrat.hpp"
#include "Form.hpp"

#include <iostream>

int main()
{
	try
	{
		Bureaucrat bob("Bob", 50);
		Form form("FormA", 49, 10);
		bob.signForm(form);
		std::cout << form << std::endl;
	}
	catch (std::exception &e)
	{
		std::cout << "Exception: " << e.what() << std::endl;
	}

	try
	{
		Bureaucrat jim("Jim", 100);
		Form form("FormB", 50, 10);
		jim.signForm(form);
		std::cout << form << std::endl;
	}
	catch (std::exception &e)
	{
		std::cout << "Exception: " << e.what() << std::endl;
	}
	return 0;
}
