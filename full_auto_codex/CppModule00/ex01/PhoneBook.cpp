#include "PhoneBook.hpp"

PhoneBook::PhoneBook()
    : m_count(0), m_nextIndex(0)
{
}

void PhoneBook::addContact(const Contact &contact)
{
    m_contacts[m_nextIndex] = contact;
    m_nextIndex = (m_nextIndex + 1) % kMaxContacts;
    if (m_count < kMaxContacts)
        ++m_count;
}

const Contact &PhoneBook::getContact(int index) const
{
    return m_contacts[index];
}

int PhoneBook::size() const
{
    return m_count;
}
