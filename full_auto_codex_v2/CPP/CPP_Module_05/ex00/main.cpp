#include "Bureaucrat.hpp"

#include <iostream>

int main()
{
	try
	{
		Bureaucrat high("High", 1);
		Bureaucrat low("Low", 150);
		std::cout << high << std::endl;
		std::cout << low << std::endl;
		low.decrementGrade();
	}
	catch (std::exception &e)
	{
		std::cout << "Exception: " << e.what() << std::endl;
	}

	try
	{
		Bureaucrat bad("Bad", 0);
		std::cout << bad << std::endl;
	}
	catch (std::exception &e)
	{
		std::cout << "Exception: " << e.what() << std::endl;
	}

	return 0;
}
