#include "Harl.hpp"

#include <iostream>

struct LevelData
{
    const char *name;
};

static const LevelData g_levels[] = {
    {"DEBUG"},
    {"INFO"},
    {"WARNING"},
    {"ERROR"}
};

void Harl::debug()
{
    std::cout << "[ DEBUG ] Desired bacon comment." << std::endl;
}

void Harl::info()
{
    std::cout << "[ INFO ] Paying for bacon complaint." << std::endl;
}

void Harl::warning()
{
    std::cout << "[ WARNING ] Expecting free bacon." << std::endl;
}

void Harl::error()
{
    std::cout << "[ ERROR ] Manager now!" << std::endl;
}

int Harl::levelFromString(const std::string &level)
{
    for (size_t i = 0; i < sizeof(g_levels) / sizeof(g_levels[0]); ++i)
    {
        if (level == g_levels[i].name)
            return static_cast<int>(i);
    }
    return -1;
}

void Harl::complain(int levelIndex)
{
    switch (levelIndex)
    {
    case 0:
        debug();
        // fallthrough
    case 1:
        info();
        // fallthrough
    case 2:
        warning();
        // fallthrough
    case 3:
        error();
        break;
    default:
        std::cout << "[ Probably complaining about insignificant problems ]" << std::endl;
    }
}
