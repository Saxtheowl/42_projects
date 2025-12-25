#include "AForm.hpp"
#include "Bureaucrat.hpp"
#include <iostream>

AForm::AForm() : _name(""), _signed(false), _gradeToSign(150), _gradeToExec(150) {}

AForm::AForm(const std::string &name, int gradeToSign, int gradeToExec)
	: _name(name), _signed(false), _gradeToSign(gradeToSign), _gradeToExec(gradeToExec)
{
	validateGrade(_gradeToSign);
	validateGrade(_gradeToExec);
}

AForm::AForm(const AForm &other)
	: _name(other._name), _signed(other._signed), _gradeToSign(other._gradeToSign), _gradeToExec(other._gradeToExec)
{
}

AForm &AForm::operator=(const AForm &other)
{
	if (this != &other)
		_signed = other._signed;
	return *this;
}

AForm::~AForm() {}

const std::string &AForm::getName() const { return _name; }

bool AForm::isSigned() const { return _signed; }

int AForm::getGradeToSign() const { return _gradeToSign; }

int AForm::getGradeToExec() const { return _gradeToExec; }

void AForm::validateGrade(int grade) const
{
	if (grade < 1)
		throw GradeTooHighException();
	if (grade > 150)
		throw GradeTooLowException();
}

void AForm::beSigned(const Bureaucrat &b)
{
	if (b.getGrade() > _gradeToSign)
		throw GradeTooLowException();
	_signed = true;
}

void AForm::validateExecution(const Bureaucrat &executor) const
{
	if (!_signed)
		throw FormNotSignedException();
	if (executor.getGrade() > _gradeToExec)
		throw GradeTooLowException();
}

const char *AForm::GradeTooHighException::what() const throw() { return "Grade too high"; }

const char *AForm::GradeTooLowException::what() const throw() { return "Grade too low"; }

const char *AForm::FormNotSignedException::what() const throw() { return "Form not signed"; }

std::ostream &operator<<(std::ostream &os, const AForm &f)
{
	os << "Form " << f.getName() << " (sign " << f.getGradeToSign() << ", exec " << f.getGradeToExec() << ") signed=" << f.isSigned();
	return os;
}
