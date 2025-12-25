#pragma once

#include <exception>
#include <string>

class Bureaucrat;

class AForm
{
public:
	AForm(const std::string &name, int gradeToSign, int gradeToExec);
	AForm(const AForm &other);
	AForm &operator=(const AForm &other);
	virtual ~AForm();

	const std::string &getName() const;
	bool isSigned() const;
	int getGradeToSign() const;
	int getGradeToExec() const;

	void beSigned(const Bureaucrat &b);

	virtual void execute(Bureaucrat const &executor) const = 0;

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

	class FormNotSignedException : public std::exception
	{
	public:
		virtual const char *what() const throw();
	};

protected:
	void validateExecution(const Bureaucrat &executor) const;

private:
	AForm();
	const std::string _name;
	bool _signed;
	const int _gradeToSign;
	const int _gradeToExec;
	void validateGrade(int grade) const;
};

std::ostream &operator<<(std::ostream &os, const AForm &f);
