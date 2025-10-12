#include "Array.hpp"

#include <iostream>
#include <string>

int main()
{
    Array<int> numbers(3);
    numbers[0] = 10;
    numbers[1] = 20;
    numbers[2] = 30;

    std::cout << "Numbers: ";
    for (unsigned int i = 0; i < numbers.size(); ++i)
        std::cout << numbers[i] << " ";
    std::cout << std::endl;

    Array<std::string> strings(2);
    strings[0] = "Hello";
    strings[1] = "World";
    std::cout << "Strings: ";
    for (unsigned int i = 0; i < strings.size(); ++i)
        std::cout << strings[i] << " ";
    std::cout << std::endl;

    try
    {
        std::cout << numbers[5] << std::endl;
    }
    catch (const std::exception &e)
    {
        std::cout << "Exception: " << e.what() << std::endl;
    }

    Array<int> copy(numbers);
    copy[1] = 200;
    std::cout << "Original numbers: ";
    for (unsigned int i = 0; i < numbers.size(); ++i)
        std::cout << numbers[i] << " ";
    std::cout << std::endl;
    std::cout << "Copy numbers: ";
    for (unsigned int i = 0; i < copy.size(); ++i)
        std::cout << copy[i] << " ";
    std::cout << std::endl;

    return 0;
}
