#include "Interpreter.hpp"

#include <exception>
#include <iostream>
#include <string>

int main()
{
    Interpreter interpreter;
    std::string line;
    while (std::cout << ">> " && std::getline(std::cin, line))
    {
        if (line.empty())
            continue;
        try
        {
            bool isAssignment = false;
            std::string name;
            Value value = interpreter.evaluate(line, isAssignment, name);
            if (isAssignment)
                std::cout << name << " = " << value.toString() << std::endl;
            else
                std::cout << value.toString() << std::endl;
        }
        catch (const std::exception &e)
        {
            std::cout << "Error: " << e.what() << std::endl;
        }
    }
    return 0;
}
