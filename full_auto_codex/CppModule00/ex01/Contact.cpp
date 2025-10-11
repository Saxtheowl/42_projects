#include "Contact.hpp"

Contact::Contact()
{
}

void Contact::setFirstName(const std::string &value)
{
    m_firstName = value;
}

void Contact::setLastName(const std::string &value)
{
    m_lastName = value;
}

void Contact::setNickname(const std::string &value)
{
    m_nickname = value;
}

void Contact::setPhoneNumber(const std::string &value)
{
    m_phoneNumber = value;
}

void Contact::setDarkestSecret(const std::string &value)
{
    m_darkestSecret = value;
}

const std::string &Contact::getFirstName() const
{
    return m_firstName;
}

const std::string &Contact::getLastName() const
{
    return m_lastName;
}

const std::string &Contact::getNickname() const
{
    return m_nickname;
}

const std::string &Contact::getPhoneNumber() const
{
    return m_phoneNumber;
}

const std::string &Contact::getDarkestSecret() const
{
    return m_darkestSecret;
}

bool Contact::isEmpty() const
{
    return m_firstName.empty() && m_lastName.empty() && m_nickname.empty()
        && m_phoneNumber.empty() && m_darkestSecret.empty();
}
