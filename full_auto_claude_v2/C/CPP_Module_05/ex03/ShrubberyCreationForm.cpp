/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   ShrubberyCreationForm.cpp                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "ShrubberyCreationForm.hpp"

ShrubberyCreationForm::ShrubberyCreationForm()
	: AForm("Shrubbery Creation", 145, 137), target("default")
{
}

ShrubberyCreationForm::ShrubberyCreationForm(const std::string& target)
	: AForm("Shrubbery Creation", 145, 137), target(target)
{
}

ShrubberyCreationForm::ShrubberyCreationForm(const ShrubberyCreationForm& other)
	: AForm(other), target(other.target)
{
}

ShrubberyCreationForm& ShrubberyCreationForm::operator=(const ShrubberyCreationForm& other)
{
	if (this != &other)
	{
		AForm::operator=(other);
		this->target = other.target;
	}
	return (*this);
}

ShrubberyCreationForm::~ShrubberyCreationForm()
{
}

void ShrubberyCreationForm::executeAction() const
{
	std::string filename = this->target + "_shrubbery";
	std::ofstream file(filename.c_str());

	if (!file.is_open())
	{
		std::cerr << "Error: Could not create file " << filename << std::endl;
		return;
	}

	file << "       ###" << std::endl;
	file << "      #o###" << std::endl;
	file << "    #####o###" << std::endl;
	file << "   #o#\\#|#/###" << std::endl;
	file << "    ###\\|/#o#" << std::endl;
	file << "     # }|{  #" << std::endl;
	file << "       }|{" << std::endl;
	file << std::endl;
	file << "      ^^^" << std::endl;
	file << "     ^^^^^" << std::endl;
	file << "    ^^^^^^^" << std::endl;
	file << "   ^^^^^^^^^" << std::endl;
	file << "      | |" << std::endl;
	file << "      | |" << std::endl;

	file.close();
	std::cout << "Shrubbery created in file: " << filename << std::endl;
}
