#ifndef PHONEBOOK_HPP
#define PHONEBOOK_HPP

#include "Contact.hpp"

class PhoneBook
{
private:
    static const int kMaxContacts = 8;
    Contact m_contacts[kMaxContacts];
    int m_count;
    int m_nextIndex;

public:
    PhoneBook();

    void addContact(const Contact &contact);
    const Contact &getContact(int index) const;
    int size() const;
};

#endif
