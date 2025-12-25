#pragma once

#include "AForm.hpp"
#include <string>

class RobotomyRequestForm : public AForm
{
public:
	RobotomyRequestForm(const std::string &target);
	RobotomyRequestForm(const RobotomyRequestForm &other);
	RobotomyRequestForm &operator=(const RobotomyRequestForm &other);
	~RobotomyRequestForm();

	virtual void execute(Bureaucrat const &executor) const;

private:
	RobotomyRequestForm();
	std::string _target;
};
