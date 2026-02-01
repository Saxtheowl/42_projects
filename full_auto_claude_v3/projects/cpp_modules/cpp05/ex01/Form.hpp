/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Form.hpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef FORM_HPP
# define FORM_HPP

# include <iostream>
# include <string>
# include <exception>
# include "Bureaucrat.hpp"

class Form
{
private:
	const std::string	_name;
	bool				_signed;
	const int			_gradeToSign;
	const int			_gradeToExecute;

public:
	Form(void);
	Form(const std::string& name, int gradeToSign, int gradeToExecute);
	Form(const Form& other);
	Form&	operator=(const Form& other);
	~Form(void);

	const std::string&	getName(void) const;
	bool				isSigned(void) const;
	int					getGradeToSign(void) const;
	int					getGradeToExecute(void) const;
	void				beSigned(const Bureaucrat& b);

	class GradeTooHighException : public std::exception {
	public:
		virtual const char*	what(void) const throw();
	};

	class GradeTooLowException : public std::exception {
	public:
		virtual const char*	what(void) const throw();
	};
};

std::ostream&	operator<<(std::ostream& os, const Form& f);

#endif
