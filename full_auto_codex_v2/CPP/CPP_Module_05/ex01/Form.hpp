#pragma once

#include <exception>
#include <string>

class Bureaucrat;

class Form
{
public:
	Form(const std::string &name, int gradeToSign, int gradeToExec);
	Form(const Form &other);
	Form &operator=(const Form &other);
	~Form();

	const std::string &getName() const;
	bool isSigned() const;
	int getGradeToSign() const;
	int getGradeToExec() const;

	void beSigned(const Bureaucrat &b);

	class GradeTooHighException : public std::exception
	{
	public:
		virtual const char *what() const throw();
	};

	class GradeTooLowException : public std::exception
	{
	public:
		virtual const char *what() const throw();
	};

private:
	Form();
	const std::string _name;
	bool _signed;
	const int _gradeToSign;
	const int _gradeToExec;
	void validateGrade(int grade) const;
};

std::ostream &operator<<(std::ostream &os, const Form &f);
