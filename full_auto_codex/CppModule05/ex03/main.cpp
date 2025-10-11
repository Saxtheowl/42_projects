#include "Bureaucrat.hpp"
#include "Intern.hpp"
#include "PresidentialPardonForm.hpp"
#include "RobotomyRequestForm.hpp"
#include "ShrubberyCreationForm.hpp"

int main()
{
    Intern someRandomIntern;
    Form *rrf = someRandomIntern.makeForm("robotomy request", "Bender");

    if (rrf)
    {
        Bureaucrat boss("Boss", 1);
        boss.signForm(*rrf);
        boss.executeForm(*rrf);
        delete rrf;
    }

    Form *unknown = someRandomIntern.makeForm("unknown", "Target");
    if (unknown)
        delete unknown;

    return 0;
}
