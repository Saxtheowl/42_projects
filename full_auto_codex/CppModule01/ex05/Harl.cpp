#include "Harl.hpp"

#include <iostream>

void Harl::debug()
{
    std::cout << "[ DEBUG ] I love to get extra bacon on my burger!" << std::endl;
}

void Harl::info()
{
    std::cout << "[ INFO ] Adding extra bacon costs more money." << std::endl;
}

void Harl::warning()
{
    std::cout << "[ WARNING ] I think I deserve some free bacon." << std::endl;
}

void Harl::error()
{
    std::cout << "[ ERROR ] This is unacceptable!" << std::endl;
}

void Harl::complain(const std::string &level)
{
    struct LevelHandler
    {
        const char *name;
        void (Harl::*method)();
    };

    const LevelHandler handlers[] = {
        {"DEBUG", &Harl::debug},
        {"INFO", &Harl::info},
        {"WARNING", &Harl::warning},
        {"ERROR", &Harl::error},
    };

    for (size_t i = 0; i < sizeof(handlers) / sizeof(handlers[0]); ++i)
    {
        if (level == handlers[i].name)
        {
            (this->*handlers[i].method)();
            return;
        }
    }
    std::cout << "[ Probably complaining about insignificant problems ]" << std::endl;
}
