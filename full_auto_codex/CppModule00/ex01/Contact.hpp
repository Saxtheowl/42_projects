#ifndef CONTACT_HPP
#define CONTACT_HPP

#include <string>

class Contact
{
private:
    std::string m_firstName;
    std::string m_lastName;
    std::string m_nickname;
    std::string m_phoneNumber;
    std::string m_darkestSecret;

public:
    Contact();

    void setFirstName(const std::string &value);
    void setLastName(const std::string &value);
    void setNickname(const std::string &value);
    void setPhoneNumber(const std::string &value);
    void setDarkestSecret(const std::string &value);

    const std::string &getFirstName() const;
    const std::string &getLastName() const;
    const std::string &getNickname() const;
    const std::string &getPhoneNumber() const;
    const std::string &getDarkestSecret() const;

    bool isEmpty() const;
};

#endif
