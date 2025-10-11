#include "Bureaucrat.hpp"
#include "PresidentialPardonForm.hpp"
#include "RobotomyRequestForm.hpp"
#include "ShrubberyCreationForm.hpp"

int main()
{
    try
    {
        Bureaucrat boss("Boss", 1);
        Bureaucrat worker("Worker", 140);

        ShrubberyCreationForm shrub("home");
        RobotomyRequestForm robo("Bender");
        PresidentialPardonForm pardon("Arthur Dent");

        worker.signForm(shrub);
        boss.signForm(shrub);
        boss.executeForm(shrub);

        boss.signForm(robo);
        boss.executeForm(robo);
        boss.executeForm(robo);

        boss.signForm(pardon);
        boss.executeForm(pardon);
    }
    catch (const std::exception &e)
    {
        std::cout << "Exception: " << e.what() << std::endl;
    }
    return 0;
}
