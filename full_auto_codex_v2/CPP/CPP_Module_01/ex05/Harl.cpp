#include "Harl.hpp"

#include <iostream>

void Harl::debug()
{
	std::cout << "[ DEBUG ] I love having extra bacon for my 7XL-double-cheese-triple-pickle-specialketchup burger." << std::endl;
}

void Harl::info()
{
	std::cout << "[ INFO ] I cannot believe adding extra bacon costs more money." << std::endl;
}

void Harl::warning()
{
	std::cout << "[ WARNING ] I think I deserve to have some extra bacon for free." << std::endl;
}

void Harl::error()
{
	std::cout << "[ ERROR ] This is unacceptable! I want to speak to the manager now." << std::endl;
}

void Harl::complain(const std::string &level)
{
	const std::string levels[] = {"DEBUG", "INFO", "WARNING", "ERROR"};
	void (Harl::*handlers[])() = {&Harl::debug, &Harl::info, &Harl::warning, &Harl::error};

	for (int i = 0; i < 4; ++i)
	{
		if (levels[i] == level)
		{
			(this->*handlers[i])();
			return;
		}
	}
}
