#include "PhoneBook.hpp"

#include <cstdlib>
#include <iostream>
#include <string>

static std::string prompt(const std::string &label)
{
	std::string input;
	std::cout << label;
	if (!std::getline(std::cin, input))
		return "";
	return input;
}

static Contact readContact()
{
	Contact c;
	c.setField("first", prompt("First name: "));
	c.setField("last", prompt("Last name: "));
	c.setField("nick", prompt("Nickname: "));
	c.setField("phone", prompt("Phone: "));
	c.setField("secret", prompt("Darkest secret: "));
	return c;
}

int main()
{
	PhoneBook book;
	std::string cmd;

	while (true)
	{
		std::cout << "Enter command (ADD, SEARCH, EXIT): ";
		if (!std::getline(std::cin, cmd))
			break;
		if (cmd == "EXIT")
			break;
		if (cmd == "ADD")
		{
			Contact c = readContact();
			if (c.isEmpty())
			{
				std::cout << "Empty contact discarded" << std::endl;
				continue;
			}
			book.addContact(c);
		}
		else if (cmd == "SEARCH")
		{
			book.displayTable();
			std::string idxStr = prompt("Index to display: ");
			if (idxStr.empty())
				continue;
			int idx = std::atoi(idxStr.c_str());
			book.displayContact(idx);
		}
	}
	return 0;
}
