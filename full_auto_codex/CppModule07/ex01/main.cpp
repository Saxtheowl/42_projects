#include "iter.hpp"

#include <iostream>
#include <string>

void printInt(int &value)
{
    std::cout << value << " ";
}

void printString(const std::string &value)
{
    std::cout << value << " ";
}

int main()
{
    int arr[] = {1, 2, 3, 4};
    std::cout << "Integers: ";
    iter(arr, 4, printInt);
    std::cout << std::endl;

    std::string strs[] = {"hello", "world", "iter"};
    std::cout << "Strings: ";
    iter(strs, 3, printString);
    std::cout << std::endl;

    return 0;
}
