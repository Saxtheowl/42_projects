/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Bureaucrat.cpp                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Bureaucrat.hpp"
#include "AForm.hpp"

Bureaucrat::Bureaucrat(void) : _name("default"), _grade(150) {}
Bureaucrat::Bureaucrat(const std::string& name, int grade) : _name(name) {
	if (grade < 1) throw GradeTooHighException();
	if (grade > 150) throw GradeTooLowException();
	_grade = grade;
}
Bureaucrat::Bureaucrat(const Bureaucrat& other) : _name(other._name), _grade(other._grade) {}
Bureaucrat& Bureaucrat::operator=(const Bureaucrat& other) { if (this != &other) _grade = other._grade; return (*this); }
Bureaucrat::~Bureaucrat(void) {}

const std::string& Bureaucrat::getName(void) const { return (_name); }
int Bureaucrat::getGrade(void) const { return (_grade); }
void Bureaucrat::incrementGrade(void) { if (_grade <= 1) throw GradeTooHighException(); _grade--; }
void Bureaucrat::decrementGrade(void) { if (_grade >= 150) throw GradeTooLowException(); _grade++; }

void Bureaucrat::signForm(AForm& form) {
	try { form.beSigned(*this); std::cout << _name << " signed " << form.getName() << std::endl; }
	catch (std::exception& e) { std::cout << _name << " couldn't sign " << form.getName() << " because " << e.what() << std::endl; }
}

void Bureaucrat::executeForm(const AForm& form) {
	try { form.execute(*this); std::cout << _name << " executed " << form.getName() << std::endl; }
	catch (std::exception& e) { std::cout << _name << " couldn't execute " << form.getName() << " because " << e.what() << std::endl; }
}

const char* Bureaucrat::GradeTooHighException::what(void) const throw() { return ("Grade is too high!"); }
const char* Bureaucrat::GradeTooLowException::what(void) const throw() { return ("Grade is too low!"); }
std::ostream& operator<<(std::ostream& os, const Bureaucrat& b) { os << b.getName() << ", bureaucrat grade " << b.getGrade(); return (os); }
