#include "ShrubberyCreationForm.hpp"
#include "Bureaucrat.hpp"

#include <fstream>
#include <iostream>

ShrubberyCreationForm::ShrubberyCreationForm(const std::string &target)
    : Form("ShrubberyCreationForm", 145, 137), m_target(target)
{
    std::cout << "ShrubberyCreationForm constructed" << std::endl;
}

ShrubberyCreationForm::ShrubberyCreationForm(const ShrubberyCreationForm &other)
    : Form(other), m_target(other.m_target)
{
    std::cout << "ShrubberyCreationForm copy constructed" << std::endl;
}

ShrubberyCreationForm &ShrubberyCreationForm::operator=(const ShrubberyCreationForm &other)
{
    Form::operator=(other);
    m_target = other.m_target;
    std::cout << "ShrubberyCreationForm copy assigned" << std::endl;
    return *this;
}

ShrubberyCreationForm::~ShrubberyCreationForm()
{
    std::cout << "ShrubberyCreationForm destroyed" << std::endl;
}

void ShrubberyCreationForm::execute(Bureaucrat const &executor) const
{
    checkExecutable(executor);
    std::ofstream ofs((m_target + "_shrubbery").c_str());
    if (!ofs)
        throw std::runtime_error("Failed to open file");
    ofs << "      /\\n";
    ofs << "     /\\\\n";
    ofs << "    /\\\\\\n";
    ofs << "   /\\\\\\\\n";
    ofs << "  /\\\\\\\\\\n";
    ofs << "     |||\n";
    ofs.close();
}
