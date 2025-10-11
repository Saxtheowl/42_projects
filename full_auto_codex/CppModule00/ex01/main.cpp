#include "PhoneBook.hpp"

#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <limits>
#include <string>

static std::string promptField(const std::string &label)
{
    std::string input;
    while (true)
    {
        std::cout << label;
        if (!std::getline(std::cin, input))
            return std::string();
        if (!input.empty())
            return input;
        std::cout << "Field cannot be empty." << std::endl;
    }
}

static std::string formatColumn(const std::string &value)
{
    if (value.length() <= 10)
        return std::string(10 - value.length(), ' ') + value;
    return value.substr(0, 9) + ".";
}

static void listContacts(const PhoneBook &book)
{
    std::cout << std::setw(10) << "index" << "|" << std::setw(10) << "first name"
              << "|" << std::setw(10) << "last name" << "|" << std::setw(10)
              << "nickname" << std::endl;
    for (int i = 0; i < book.size(); ++i)
    {
        const Contact &contact = book.getContact(i);
        std::cout << std::setw(10) << i << "|" << formatColumn(contact.getFirstName())
                  << "|" << formatColumn(contact.getLastName()) << "|"
                  << formatColumn(contact.getNickname()) << std::endl;
    }
}

static void displayContact(const Contact &contact)
{
    std::cout << "First name: " << contact.getFirstName() << std::endl;
    std::cout << "Last name: " << contact.getLastName() << std::endl;
    std::cout << "Nickname: " << contact.getNickname() << std::endl;
    std::cout << "Phone number: " << contact.getPhoneNumber() << std::endl;
    std::cout << "Darkest secret: " << contact.getDarkestSecret() << std::endl;
}

int main()
{
    PhoneBook book;
    std::string command;

    while (true)
    {
        std::cout << "Enter command (ADD, SEARCH, EXIT): ";
        if (!std::getline(std::cin, command))
            break;
        if (command == "EXIT")
            break;
        else if (command == "ADD")
        {
            Contact contact;
            std::string firstName = promptField("First name: ");
            if (firstName.empty())
                break;
            contact.setFirstName(firstName);
            contact.setLastName(promptField("Last name: "));
            contact.setNickname(promptField("Nickname: "));
            contact.setPhoneNumber(promptField("Phone number: "));
            contact.setDarkestSecret(promptField("Darkest secret: "));
            book.addContact(contact);
            std::cout << "Contact added." << std::endl;
        }
        else if (command == "SEARCH")
        {
            if (book.size() == 0)
            {
                std::cout << "PhoneBook is empty." << std::endl;
                continue;
            }
            listContacts(book);
            std::cout << "Select index: ";
            std::string indexStr;
            if (!std::getline(std::cin, indexStr))
                break;
            if (indexStr.empty() || indexStr.find_first_not_of("0123456789") != std::string::npos)
            {
                std::cout << "Invalid index." << std::endl;
                continue;
            }
            int index = std::atoi(indexStr.c_str());
            if (index < 0 || index >= book.size())
            {
                std::cout << "Index out of range." << std::endl;
                continue;
            }
            displayContact(book.getContact(index));
        }
        else if (!command.empty())
        {
            std::cout << "Unknown command." << std::endl;
        }
    }
    return 0;
}
