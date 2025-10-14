/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   AForm.cpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "AForm.hpp"
#include "Bureaucrat.hpp"

AForm::AForm() : name("Default"), isSigned(false), gradeToSign(150), gradeToExecute(150)
{
}

AForm::AForm(const std::string& name, int gradeToSign, int gradeToExecute)
	: name(name), isSigned(false), gradeToSign(gradeToSign), gradeToExecute(gradeToExecute)
{
	if (gradeToSign < 1 || gradeToExecute < 1)
		throw AForm::GradeTooHighException();
	if (gradeToSign > 150 || gradeToExecute > 150)
		throw AForm::GradeTooLowException();
}

AForm::AForm(const AForm& other)
	: name(other.name), isSigned(other.isSigned), gradeToSign(other.gradeToSign), gradeToExecute(other.gradeToExecute)
{
}

AForm& AForm::operator=(const AForm& other)
{
	if (this != &other)
	{
		// Note: name, gradeToSign, gradeToExecute are const, can only copy isSigned
		this->isSigned = other.isSigned;
	}
	return (*this);
}

AForm::~AForm()
{
}

std::string AForm::getName() const
{
	return (this->name);
}

bool AForm::getSigned() const
{
	return (this->isSigned);
}

int AForm::getGradeToSign() const
{
	return (this->gradeToSign);
}

int AForm::getGradeToExecute() const
{
	return (this->gradeToExecute);
}

void AForm::beSigned(const Bureaucrat& bureaucrat)
{
	if (bureaucrat.getGrade() > this->gradeToSign)
		throw AForm::GradeTooLowException();
	this->isSigned = true;
}

void AForm::execute(const Bureaucrat& executor) const
{
	if (!this->isSigned)
		throw AForm::FormNotSignedException();
	if (executor.getGrade() > this->gradeToExecute)
		throw AForm::GradeTooLowException();
	this->executeAction();
}

const char* AForm::GradeTooHighException::what() const throw()
{
	return ("Form grade is too high!");
}

const char* AForm::GradeTooLowException::what() const throw()
{
	return ("Form grade is too low!");
}

const char* AForm::FormNotSignedException::what() const throw()
{
	return ("Form is not signed!");
}

std::ostream& operator<<(std::ostream& out, const AForm& form)
{
	out << "Form " << form.getName() << ", signed: " << (form.getSigned() ? "yes" : "no")
		<< ", grade to sign: " << form.getGradeToSign()
		<< ", grade to execute: " << form.getGradeToExecute();
	return (out);
}
