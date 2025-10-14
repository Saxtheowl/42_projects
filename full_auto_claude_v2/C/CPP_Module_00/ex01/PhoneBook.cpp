/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   PhoneBook.cpp                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "PhoneBook.hpp"

PhoneBook::PhoneBook() : currentIndex(0), contactCount(0)
{
}

PhoneBook::~PhoneBook()
{
}

std::string	PhoneBook::truncate(const std::string& str, size_t width) const
{
	if (str.length() > width)
		return (str.substr(0, width - 1) + ".");
	return (str);
}

void	PhoneBook::displayHeader() const
{
	std::cout << std::setw(10) << std::right << "Index" << "|";
	std::cout << std::setw(10) << std::right << "First Name" << "|";
	std::cout << std::setw(10) << std::right << "Last Name" << "|";
	std::cout << std::setw(10) << std::right << "Nickname" << std::endl;
}

void	PhoneBook::displayContactRow(int index) const
{
	std::cout << std::setw(10) << std::right << index << "|";
	std::cout << std::setw(10) << std::right
			  << truncate(contacts[index].getFirstName(), 10) << "|";
	std::cout << std::setw(10) << std::right
			  << truncate(contacts[index].getLastName(), 10) << "|";
	std::cout << std::setw(10) << std::right
			  << truncate(contacts[index].getNickname(), 10) << std::endl;
}

void	PhoneBook::addContact()
{
	std::string	input;

	std::cout << "Enter first name: ";
	std::getline(std::cin, input);
	if (std::cin.eof())
		return ;
	contacts[currentIndex].setFirstName(input);

	std::cout << "Enter last name: ";
	std::getline(std::cin, input);
	if (std::cin.eof())
		return ;
	contacts[currentIndex].setLastName(input);

	std::cout << "Enter nickname: ";
	std::getline(std::cin, input);
	if (std::cin.eof())
		return ;
	contacts[currentIndex].setNickname(input);

	std::cout << "Enter phone number: ";
	std::getline(std::cin, input);
	if (std::cin.eof())
		return ;
	contacts[currentIndex].setPhoneNumber(input);

	std::cout << "Enter darkest secret: ";
	std::getline(std::cin, input);
	if (std::cin.eof())
		return ;
	contacts[currentIndex].setDarkestSecret(input);

	currentIndex = (currentIndex + 1) % 8;
	if (contactCount < 8)
		contactCount++;

	std::cout << "Contact added successfully!" << std::endl;
}

void	PhoneBook::searchContact() const
{
	int	index;

	if (contactCount == 0)
	{
		std::cout << "PhoneBook is empty!" << std::endl;
		return ;
	}

	displayHeader();
	for (int i = 0; i < contactCount; i++)
	{
		if (!contacts[i].isEmpty())
			displayContactRow(i);
	}

	std::cout << "Enter index to display: ";
	std::cin >> index;

	if (std::cin.fail())
	{
		std::cin.clear();
		std::cin.ignore(10000, '\n');
		std::cout << "Invalid input!" << std::endl;
		return ;
	}

	std::cin.ignore(10000, '\n');

	if (index < 0 || index >= contactCount || contacts[index].isEmpty())
	{
		std::cout << "Invalid index!" << std::endl;
		return ;
	}

	contacts[index].display();
}
