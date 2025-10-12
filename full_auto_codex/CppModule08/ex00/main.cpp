#include "easyfind.hpp"

#include <iostream>
#include <list>
#include <vector>

int main()
{
    std::vector<int> vec;
    vec.push_back(1);
    vec.push_back(2);
    vec.push_back(3);

    try
    {
        std::vector<int>::iterator it = easyfind(vec, 2);
        std::cout << "Found in vector: " << *it << std::endl;
        easyfind(vec, 42);
    }
    catch (const std::exception &e)
    {
        std::cout << "Vector: " << e.what() << std::endl;
    }

    std::list<int> lst;
    lst.push_back(10);
    lst.push_back(20);
    lst.push_back(30);
    try
    {
        std::list<int>::const_iterator it = easyfind(lst, 20);
        std::cout << "Found in list: " << *it << std::endl;
        easyfind(lst, 100);
    }
    catch (const std::exception &e)
    {
        std::cout << "List: " << e.what() << std::endl;
    }

    return 0;
}
