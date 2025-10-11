#ifndef INTERN_HPP
#define INTERN_HPP

#include <string>

class Form;

class Intern
{
public:
    Intern();
    Intern(const Intern &other);
    Intern &operator=(const Intern &other);
    ~Intern();

    Form *makeForm(const std::string &formName, const std::string &target) const;
};

#endif
