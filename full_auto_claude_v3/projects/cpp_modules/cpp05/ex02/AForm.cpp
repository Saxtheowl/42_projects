/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   AForm.cpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "AForm.hpp"

AForm::AForm(void) : _name("default"), _signed(false), _gradeToSign(150), _gradeToExecute(150) {}
AForm::AForm(const std::string& name, int gradeToSign, int gradeToExecute)
	: _name(name), _signed(false), _gradeToSign(gradeToSign), _gradeToExecute(gradeToExecute) {
	if (gradeToSign < 1 || gradeToExecute < 1) throw GradeTooHighException();
	if (gradeToSign > 150 || gradeToExecute > 150) throw GradeTooLowException();
}
AForm::AForm(const AForm& other) : _name(other._name), _signed(other._signed), _gradeToSign(other._gradeToSign), _gradeToExecute(other._gradeToExecute) {}
AForm& AForm::operator=(const AForm& other) { if (this != &other) _signed = other._signed; return (*this); }
AForm::~AForm(void) {}

const std::string& AForm::getName(void) const { return (_name); }
bool AForm::isSigned(void) const { return (_signed); }
int AForm::getGradeToSign(void) const { return (_gradeToSign); }
int AForm::getGradeToExecute(void) const { return (_gradeToExecute); }

void AForm::beSigned(const Bureaucrat& b) {
	if (b.getGrade() > _gradeToSign) throw GradeTooLowException();
	_signed = true;
}

const char* AForm::GradeTooHighException::what(void) const throw() { return ("Grade is too high!"); }
const char* AForm::GradeTooLowException::what(void) const throw() { return ("Grade is too low!"); }
const char* AForm::FormNotSignedException::what(void) const throw() { return ("Form is not signed!"); }

std::ostream& operator<<(std::ostream& os, const AForm& f) {
	os << "Form " << f.getName() << " [signed: " << (f.isSigned() ? "yes" : "no")
	   << ", sign: " << f.getGradeToSign() << ", exec: " << f.getGradeToExecute() << "]";
	return (os);
}
