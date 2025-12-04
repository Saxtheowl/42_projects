#ifndef CONTACT_HPP
#define CONTACT_HPP

#include <string>

class Contact
{
public:
	Contact();

	void setField(const std::string &fieldName, const std::string &value);

	const std::string &getFirstName() const;
	const std::string &getLastName() const;
	const std::string &getNickname() const;
	const std::string &getPhone() const;
	const std::string &getSecret() const;

	bool isEmpty() const;

private:
	std::string _firstName;
	std::string _lastName;
	std::string _nickname;
	std::string _phone;
	std::string _secret;
};

#endif // CONTACT_HPP
