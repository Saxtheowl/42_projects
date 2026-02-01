/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Form.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Form.hpp"

Form::Form(void) : _name("default"), _signed(false), _gradeToSign(150), _gradeToExecute(150) {}

Form::Form(const std::string& name, int gradeToSign, int gradeToExecute)
	: _name(name), _signed(false), _gradeToSign(gradeToSign), _gradeToExecute(gradeToExecute) {
	if (gradeToSign < 1 || gradeToExecute < 1) throw GradeTooHighException();
	if (gradeToSign > 150 || gradeToExecute > 150) throw GradeTooLowException();
}

Form::Form(const Form& other)
	: _name(other._name), _signed(other._signed), _gradeToSign(other._gradeToSign), _gradeToExecute(other._gradeToExecute) {}

Form& Form::operator=(const Form& other) {
	if (this != &other) _signed = other._signed;
	return (*this);
}

Form::~Form(void) {}

const std::string& Form::getName(void) const { return (_name); }
bool Form::isSigned(void) const { return (_signed); }
int Form::getGradeToSign(void) const { return (_gradeToSign); }
int Form::getGradeToExecute(void) const { return (_gradeToExecute); }

void Form::beSigned(const Bureaucrat& b) {
	if (b.getGrade() > _gradeToSign) throw GradeTooLowException();
	_signed = true;
}

const char* Form::GradeTooHighException::what(void) const throw() { return ("Grade is too high!"); }
const char* Form::GradeTooLowException::what(void) const throw() { return ("Grade is too low!"); }

std::ostream& operator<<(std::ostream& os, const Form& f) {
	os << "Form " << f.getName() << " [signed: " << (f.isSigned() ? "yes" : "no")
	   << ", sign grade: " << f.getGradeToSign() << ", exec grade: " << f.getGradeToExecute() << "]";
	return (os);
}
