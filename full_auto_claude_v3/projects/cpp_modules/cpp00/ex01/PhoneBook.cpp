/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   PhoneBook.cpp                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "PhoneBook.hpp"

PhoneBook::PhoneBook(void) : _index(0), _count(0) {}

PhoneBook::~PhoneBook(void) {}

std::string	PhoneBook::_truncate(std::string str) const
{
	if (str.length() > 10)
		return (str.substr(0, 9) + ".");
	return (str);
}

void	PhoneBook::_displayHeader(void) const
{
	std::cout << "|" << std::setw(10) << "Index";
	std::cout << "|" << std::setw(10) << "First Name";
	std::cout << "|" << std::setw(10) << "Last Name";
	std::cout << "|" << std::setw(10) << "Nickname";
	std::cout << "|" << std::endl;
	std::cout << "|----------|----------|----------|----------|" << std::endl;
}

void	PhoneBook::_displayContact(int index) const
{
	std::cout << "|" << std::setw(10) << index;
	std::cout << "|" << std::setw(10) << _truncate(_contacts[index].getFirstName());
	std::cout << "|" << std::setw(10) << _truncate(_contacts[index].getLastName());
	std::cout << "|" << std::setw(10) << _truncate(_contacts[index].getNickname());
	std::cout << "|" << std::endl;
}

static std::string	getInput(std::string prompt)
{
	std::string	input;

	while (input.empty())
	{
		std::cout << prompt;
		if (!std::getline(std::cin, input))
			return ("");
		if (input.empty())
			std::cout << "Field cannot be empty!" << std::endl;
	}
	return (input);
}

void	PhoneBook::addContact(void)
{
	std::string	input;

	input = getInput("Enter first name: ");
	if (input.empty())
		return ;
	_contacts[_index].setFirstName(input);

	input = getInput("Enter last name: ");
	if (input.empty())
		return ;
	_contacts[_index].setLastName(input);

	input = getInput("Enter nickname: ");
	if (input.empty())
		return ;
	_contacts[_index].setNickname(input);

	input = getInput("Enter phone number: ");
	if (input.empty())
		return ;
	_contacts[_index].setPhoneNumber(input);

	input = getInput("Enter darkest secret: ");
	if (input.empty())
		return ;
	_contacts[_index].setDarkestSecret(input);

	std::cout << "Contact added successfully!" << std::endl;
	_index = (_index + 1) % 8;
	if (_count < 8)
		_count++;
}

void	PhoneBook::searchContact(void) const
{
	std::string	input;
	int			index;

	if (_count == 0)
	{
		std::cout << "PhoneBook is empty!" << std::endl;
		return ;
	}
	_displayHeader();
	for (int i = 0; i < _count; i++)
		_displayContact(i);
	std::cout << "Enter index: ";
	if (!std::getline(std::cin, input))
		return ;
	if (input.length() != 1 || input[0] < '0' || input[0] > '7')
	{
		std::cout << "Invalid index!" << std::endl;
		return ;
	}
	index = input[0] - '0';
	if (index >= _count)
	{
		std::cout << "Index out of range!" << std::endl;
		return ;
	}
	std::cout << "First Name: " << _contacts[index].getFirstName() << std::endl;
	std::cout << "Last Name: " << _contacts[index].getLastName() << std::endl;
	std::cout << "Nickname: " << _contacts[index].getNickname() << std::endl;
	std::cout << "Phone Number: " << _contacts[index].getPhoneNumber() << std::endl;
	std::cout << "Darkest Secret: " << _contacts[index].getDarkestSecret() << std::endl;
}
