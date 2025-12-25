#include "Form.hpp"
#include "Bureaucrat.hpp"

Form::Form() : _name(""), _signed(false), _gradeToSign(150), _gradeToExec(150) {}

Form::Form(const std::string &name, int gradeToSign, int gradeToExec)
	: _name(name), _signed(false), _gradeToSign(gradeToSign), _gradeToExec(gradeToExec)
{
	validateGrade(_gradeToSign);
	validateGrade(_gradeToExec);
}

Form::Form(const Form &other)
	: _name(other._name), _signed(other._signed), _gradeToSign(other._gradeToSign), _gradeToExec(other._gradeToExec)
{
}

Form &Form::operator=(const Form &other)
{
	if (this != &other)
	{
		_signed = other._signed;
	}
	return *this;
}

Form::~Form() {}

const std::string &Form::getName() const { return _name; }

bool Form::isSigned() const { return _signed; }

int Form::getGradeToSign() const { return _gradeToSign; }

int Form::getGradeToExec() const { return _gradeToExec; }

void Form::validateGrade(int grade) const
{
	if (grade < 1)
		throw GradeTooHighException();
	if (grade > 150)
		throw GradeTooLowException();
}

void Form::beSigned(const Bureaucrat &b)
{
	if (b.getGrade() > _gradeToSign)
		throw GradeTooLowException();
	_signed = true;
}

const char *Form::GradeTooHighException::what() const throw() { return "Grade too high"; }

const char *Form::GradeTooLowException::what() const throw() { return "Grade too low"; }

std::ostream &operator<<(std::ostream &os, const Form &f)
{
	os << "Form " << f.getName() << " (sign " << f.getGradeToSign() << ", exec " << f.getGradeToExec() << ") signed=" << f.isSigned();
	return os;
}
