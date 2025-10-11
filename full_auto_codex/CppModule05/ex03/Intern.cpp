#include "Intern.hpp"
#include "PresidentialPardonForm.hpp"
#include "RobotomyRequestForm.hpp"
#include "ShrubberyCreationForm.hpp"

#include <iostream>

Intern::Intern()
{
    std::cout << "Intern constructed" << std::endl;
}

Intern::Intern(const Intern &other)
{
    (void)other;
    std::cout << "Intern copy constructed" << std::endl;
}

Intern &Intern::operator=(const Intern &other)
{
    (void)other;
    std::cout << "Intern copy assigned" << std::endl;
    return *this;
}

Intern::~Intern()
{
    std::cout << "Intern destroyed" << std::endl;
}

Form *Intern::makeForm(const std::string &formName, const std::string &target) const
{
    const std::string names[] = {
        "shrubbery creation",
        "robotomy request",
        "presidential pardon"
    };

    if (formName == names[0])
    {
        std::cout << "Intern creates " << formName << std::endl;
        return new ShrubberyCreationForm(target);
    }
    if (formName == names[1])
    {
        std::cout << "Intern creates " << formName << std::endl;
        return new RobotomyRequestForm(target);
    }
    if (formName == names[2])
    {
        std::cout << "Intern creates " << formName << std::endl;
        return new PresidentialPardonForm(target);
    }
    std::cout << "Intern cannot create form " << formName << std::endl;
    return 0;
}
