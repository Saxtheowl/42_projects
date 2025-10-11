#include "Bureaucrat.hpp"
#include "Form.hpp"

int main()
{
    try
    {
        Bureaucrat chief("Chief", 1);
        Bureaucrat intern("Intern", 150);
        Form formA("FormA", 50, 30);

        intern.signForm(formA);
        chief.signForm(formA);
        std::cout << formA << std::endl;
    }
    catch (const std::exception &e)
    {
        std::cout << "Exception: " << e.what() << std::endl;
    }

    try
    {
        Form invalid("ImpossibleForm", 0, 10);
    }
    catch (const std::exception &e)
    {
        std::cout << "Exception: " << e.what() << std::endl;
    }

    return 0;
}
