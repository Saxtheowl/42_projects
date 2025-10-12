#include "Span.hpp"

#include <cstdlib>
#include <ctime>
#include <iostream>
#include <vector>

int main()
{
    try
    {
        Span sp(5);
        sp.addNumber(6);
        sp.addNumber(3);
        sp.addNumber(17);
        sp.addNumber(9);
        sp.addNumber(11);
        std::cout << "Shortest span: " << sp.shortestSpan() << std::endl;
        std::cout << "Longest span: " << sp.longestSpan() << std::endl;
    }
    catch (const std::exception &e)
    {
        std::cout << "Exception: " << e.what() << std::endl;
    }

    Span large(10000);
    std::vector<int> values;
    for (int i = 0; i < 10000; ++i)
        values.push_back(i);
    large.addRange(values.begin(), values.end());
    std::cout << "Large shortest: " << large.shortestSpan() << std::endl;
    std::cout << "Large longest: " << large.longestSpan() << std::endl;

    return 0;
}
