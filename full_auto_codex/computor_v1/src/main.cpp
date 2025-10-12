#include "Computor.hpp"

#include <exception>
#include <iostream>

int main(int argc, char **argv)
{
    if (argc != 2)
    {
        std::cout << "Usage: " << argv[0] << " \"<polynomial equation>\"" << std::endl;
        return 1;
    }

    try
    {
        Polynomial poly = parseEquation(argv[1]);
        printReducedForm(poly);
        solveEquation(poly);
    }
    catch (const std::exception &e)
    {
        std::cout << "Error: " << e.what() << std::endl;
        return 1;
    }

    return 0;
}
