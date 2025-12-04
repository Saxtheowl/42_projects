#include "PhoneBook.hpp"

#include <iomanip>
#include <iostream>

PhoneBook::PhoneBook() : _count(0), _nextIndex(0) {}

void PhoneBook::addContact(const Contact &contact)
{
	_contacts[_nextIndex] = contact;
	_nextIndex = (_nextIndex + 1) % 8;
	if (_count < 8)
		++_count;
}

std::string PhoneBook::formatCell(const std::string &value) const
{
	if (value.length() > 10)
		return value.substr(0, 9) + ".";
	if (value.length() < 10)
		return std::string(10 - value.length(), ' ') + value;
	return value;
}

void PhoneBook::displayTable() const
{
	std::cout << std::setw(10) << "Index" << "|"
			  << std::setw(10) << "First" << "|"
			  << std::setw(10) << "Last" << "|"
			  << std::setw(10) << "Nick" << std::endl;
	for (int i = 0; i < _count; ++i)
	{
		std::cout << std::setw(10) << i << "|"
				  << formatCell(_contacts[i].getFirstName()) << "|"
				  << formatCell(_contacts[i].getLastName()) << "|"
				  << formatCell(_contacts[i].getNickname()) << std::endl;
	}
}

void PhoneBook::displayContact(int index) const
{
	if (index < 0 || index >= _count)
	{
		std::cout << "Invalid index" << std::endl;
		return;
	}
	const Contact &c = _contacts[index];
	std::cout << "First name: " << c.getFirstName() << std::endl;
	std::cout << "Last name: " << c.getLastName() << std::endl;
	std::cout << "Nickname: " << c.getNickname() << std::endl;
	std::cout << "Phone: " << c.getPhone() << std::endl;
	std::cout << "Secret: " << c.getSecret() << std::endl;
}
