#ifndef PHONEBOOK_HPP
#define PHONEBOOK_HPP

#include "Contact.hpp"

class PhoneBook
{
public:
	PhoneBook();

	void addContact(const Contact &contact);
	void displayTable() const;
	void displayContact(int index) const;

private:
	Contact _contacts[8];
	int _count;
	int _nextIndex;

	std::string formatCell(const std::string &value) const;
};

#endif // PHONEBOOK_HPP
