#include "Base.hpp"

#include <cstdlib>
#include <ctime>
#include <iostream>

Base::~Base()
{
}

Base *generate(void)
{
    static bool seeded = false;
    if (!seeded)
    {
        std::srand(static_cast<unsigned int>(std::time(NULL)));
        seeded = true;
    }
    int r = std::rand() % 3;
    switch (r)
    {
    case 0:
        std::cout << "Generated A" << std::endl;
        return new A();
    case 1:
        std::cout << "Generated B" << std::endl;
        return new B();
    default:
        std::cout << "Generated C" << std::endl;
        return new C();
    }
}

void identify(Base *p)
{
    if (dynamic_cast<A *>(p))
        std::cout << "A" << std::endl;
    else if (dynamic_cast<B *>(p))
        std::cout << "B" << std::endl;
    else if (dynamic_cast<C *>(p))
        std::cout << "C" << std::endl;
    else
        std::cout << "Unknown" << std::endl;
}

void identify(Base &p)
{
    try
    {
        (void)dynamic_cast<A &>(p);
        std::cout << "A" << std::endl;
        return;
    }
    catch (const std::exception &)
    {
    }
    try
    {
        (void)dynamic_cast<B &>(p);
        std::cout << "B" << std::endl;
        return;
    }
    catch (const std::exception &)
    {
    }
    try
    {
        (void)dynamic_cast<C &>(p);
        std::cout << "C" << std::endl;
        return;
    }
    catch (const std::exception &)
    {
    }
    std::cout << "Unknown" << std::endl;
}
