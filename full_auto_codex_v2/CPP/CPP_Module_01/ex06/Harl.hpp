#pragma once

#include <string>

class Harl
{
public:
	void complain(const std::string &level);

private:
	void debug();
	void info();
	void warning();
	void error();
};
