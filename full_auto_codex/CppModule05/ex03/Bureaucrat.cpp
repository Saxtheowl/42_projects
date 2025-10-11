#include "Bureaucrat.hpp"
#include "Form.hpp"

Bureaucrat::Bureaucrat(const std::string &name, int grade)
    : m_name(name), m_grade(grade)
{
    if (grade < 1)
        throw GradeTooHighException();
    if (grade > 150)
        throw GradeTooLowException();
    std::cout << "Bureaucrat " << m_name << " constructed" << std::endl;
}

Bureaucrat::Bureaucrat(const Bureaucrat &other)
    : m_name(other.m_name), m_grade(other.m_grade)
{
    std::cout << "Bureaucrat copy constructed" << std::endl;
}

Bureaucrat &Bureaucrat::operator=(const Bureaucrat &other)
{
    if (this != &other)
        m_grade = other.m_grade;
    std::cout << "Bureaucrat copy assigned" << std::endl;
    return *this;
}

Bureaucrat::~Bureaucrat()
{
    std::cout << "Bureaucrat " << m_name << " destroyed" << std::endl;
}

const std::string &Bureaucrat::getName() const
{
    return m_name;
}

int Bureaucrat::getGrade() const
{
    return m_grade;
}

void Bureaucrat::incrementGrade()
{
    if (m_grade <= 1)
        throw GradeTooHighException();
    --m_grade;
}

void Bureaucrat::decrementGrade()
{
    if (m_grade >= 150)
        throw GradeTooLowException();
    ++m_grade;
}

void Bureaucrat::signForm(Form &form) const
{
    try
    {
        form.beSigned(*this);
        std::cout << m_name << " signed " << form.getName() << std::endl;
    }
    catch (const std::exception &e)
    {
        std::cout << m_name << " couldn't sign " << form.getName() << " because " << e.what() << std::endl;
    }
}

void Bureaucrat::executeForm(const Form &form) const
{
    try
    {
        form.execute(*this);
        std::cout << m_name << " executed " << form.getName() << std::endl;
    }
    catch (const std::exception &e)
    {
        std::cout << m_name << " couldn't execute " << form.getName() << " because " << e.what() << std::endl;
    }
}

const char *Bureaucrat::GradeTooHighException::what() const throw()
{
    return "Grade too high";
}

const char *Bureaucrat::GradeTooLowException::what() const throw()
{
    return "Grade too low";
}

std::ostream &operator<<(std::ostream &os, const Bureaucrat &bureaucrat)
{
    os << bureaucrat.getName() << ", bureaucrat grade " << bureaucrat.getGrade();
    return os;
}
