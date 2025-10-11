#include "PresidentialPardonForm.hpp"
#include "Bureaucrat.hpp"

#include <iostream>

PresidentialPardonForm::PresidentialPardonForm(const std::string &target)
    : Form("PresidentialPardonForm", 25, 5), m_target(target)
{
    std::cout << "PresidentialPardonForm constructed" << std::endl;
}

PresidentialPardonForm::PresidentialPardonForm(const PresidentialPardonForm &other)
    : Form(other), m_target(other.m_target)
{
    std::cout << "PresidentialPardonForm copy constructed" << std::endl;
}

PresidentialPardonForm &PresidentialPardonForm::operator=(const PresidentialPardonForm &other)
{
    Form::operator=(other);
    m_target = other.m_target;
    std::cout << "PresidentialPardonForm copy assigned" << std::endl;
    return *this;
}

PresidentialPardonForm::~PresidentialPardonForm()
{
    std::cout << "PresidentialPardonForm destroyed" << std::endl;
}

void PresidentialPardonForm::execute(Bureaucrat const &executor) const
{
    checkExecutable(executor);
    std::cout << m_target << " has been pardoned by Zaphod Beeblebrox" << std::endl;
}
