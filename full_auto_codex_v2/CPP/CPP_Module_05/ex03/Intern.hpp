#pragma once

#include "AForm.hpp"
#include <string>

class Intern
{
public:
	Intern();
	Intern(const Intern &other);
	Intern &operator=(const Intern &other);
	~Intern();

	AForm *makeForm(const std::string &formName, const std::string &target) const;

	class UnknownFormException : public std::exception
	{
	public:
		virtual const char *what() const throw();
	};
};
