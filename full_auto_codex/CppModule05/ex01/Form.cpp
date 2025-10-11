#include "Form.hpp"
#include "Bureaucrat.hpp"

Form::Form(const std::string &name, int signGrade, int execGrade)
    : m_name(name), m_signed(false), m_signGrade(signGrade), m_execGrade(execGrade)
{
    if (signGrade < 1 || execGrade < 1)
        throw GradeTooHighException();
    if (signGrade > 150 || execGrade > 150)
        throw GradeTooLowException();
    std::cout << "Form " << m_name << " constructed" << std::endl;
}

Form::Form(const Form &other)
    : m_name(other.m_name), m_signed(other.m_signed), m_signGrade(other.m_signGrade), m_execGrade(other.m_execGrade)
{
    std::cout << "Form copy constructed" << std::endl;
}

Form &Form::operator=(const Form &other)
{
    if (this != &other)
        m_signed = other.m_signed;
    std::cout << "Form copy assigned" << std::endl;
    return *this;
}

Form::~Form()
{
    std::cout << "Form " << m_name << " destroyed" << std::endl;
}

const std::string &Form::getName() const
{
    return m_name;
}

bool Form::isSigned() const
{
    return m_signed;
}

int Form::getSignGrade() const
{
    return m_signGrade;
}

int Form::getExecGrade() const
{
    return m_execGrade;
}

void Form::beSigned(const Bureaucrat &bureaucrat)
{
    if (bureaucrat.getGrade() > m_signGrade)
        throw GradeTooLowException();
    m_signed = true;
}

const char *Form::GradeTooHighException::what() const throw()
{
    return "Form grade too high";
}

const char *Form::GradeTooLowException::what() const throw()
{
    return "Form grade too low";
}

std::ostream &operator<<(std::ostream &os, const Form &form)
{
    os << "Form " << form.getName() << ", signed: " << (form.isSigned() ? "yes" : "no")
       << ", sign grade: " << form.getSignGrade() << ", execute grade: " << form.getExecGrade();
    return os;
}
