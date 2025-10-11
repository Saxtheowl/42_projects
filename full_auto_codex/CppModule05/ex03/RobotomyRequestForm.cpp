#include "RobotomyRequestForm.hpp"
#include "Bureaucrat.hpp"

#include <cstdlib>
#include <ctime>
#include <iostream>

RobotomyRequestForm::RobotomyRequestForm(const std::string &target)
    : Form("RobotomyRequestForm", 72, 45), m_target(target)
{
    std::cout << "RobotomyRequestForm constructed" << std::endl;
    std::srand(static_cast<unsigned int>(std::time(NULL)));
}

RobotomyRequestForm::RobotomyRequestForm(const RobotomyRequestForm &other)
    : Form(other), m_target(other.m_target)
{
    std::cout << "RobotomyRequestForm copy constructed" << std::endl;
}

RobotomyRequestForm &RobotomyRequestForm::operator=(const RobotomyRequestForm &other)
{
    Form::operator=(other);
    m_target = other.m_target;
    std::cout << "RobotomyRequestForm copy assigned" << std::endl;
    return *this;
}

RobotomyRequestForm::~RobotomyRequestForm()
{
    std::cout << "RobotomyRequestForm destroyed" << std::endl;
}

void RobotomyRequestForm::execute(Bureaucrat const &executor) const
{
    checkExecutable(executor);
    std::cout << "* drilling noises *" << std::endl;
    if (std::rand() % 2)
        std::cout << m_target << " has been robotomized successfully" << std::endl;
    else
        std::cout << "Robotomy failed on " << m_target << std::endl;
}
