/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Form.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Form.hpp"
#include "Bureaucrat.hpp"

Form::Form() : name("Default"), isSigned(false), gradeToSign(150), gradeToExecute(150)
{
}

Form::Form(const std::string& name, int gradeToSign, int gradeToExecute)
	: name(name), isSigned(false), gradeToSign(gradeToSign), gradeToExecute(gradeToExecute)
{
	if (gradeToSign < 1 || gradeToExecute < 1)
		throw Form::GradeTooHighException();
	if (gradeToSign > 150 || gradeToExecute > 150)
		throw Form::GradeTooLowException();
}

Form::Form(const Form& other)
	: name(other.name), isSigned(other.isSigned), gradeToSign(other.gradeToSign), gradeToExecute(other.gradeToExecute)
{
}

Form& Form::operator=(const Form& other)
{
	if (this != &other)
	{
		// Note: name, gradeToSign, gradeToExecute are const, can only copy isSigned
		this->isSigned = other.isSigned;
	}
	return (*this);
}

Form::~Form()
{
}

std::string Form::getName() const
{
	return (this->name);
}

bool Form::getSigned() const
{
	return (this->isSigned);
}

int Form::getGradeToSign() const
{
	return (this->gradeToSign);
}

int Form::getGradeToExecute() const
{
	return (this->gradeToExecute);
}

void Form::beSigned(const Bureaucrat& bureaucrat)
{
	if (bureaucrat.getGrade() > this->gradeToSign)
		throw Form::GradeTooLowException();
	this->isSigned = true;
}

const char* Form::GradeTooHighException::what() const throw()
{
	return ("Form grade is too high!");
}

const char* Form::GradeTooLowException::what() const throw()
{
	return ("Form grade is too low!");
}

std::ostream& operator<<(std::ostream& out, const Form& form)
{
	out << "Form " << form.getName() << ", signed: " << (form.getSigned() ? "yes" : "no")
		<< ", grade to sign: " << form.getGradeToSign()
		<< ", grade to execute: " << form.getGradeToExecute();
	return (out);
}
