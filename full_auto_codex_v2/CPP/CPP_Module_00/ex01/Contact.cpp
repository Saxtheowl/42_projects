#include "Contact.hpp"

Contact::Contact()
	: _firstName(), _lastName(), _nickname(), _phone(), _secret()
{
}

void Contact::setField(const std::string &fieldName, const std::string &value)
{
	if (fieldName == "first")
		_firstName = value;
	else if (fieldName == "last")
		_lastName = value;
	else if (fieldName == "nick")
		_nickname = value;
	else if (fieldName == "phone")
		_phone = value;
	else if (fieldName == "secret")
		_secret = value;
}

const std::string &Contact::getFirstName() const { return _firstName; }
const std::string &Contact::getLastName() const { return _lastName; }
const std::string &Contact::getNickname() const { return _nickname; }
const std::string &Contact::getPhone() const { return _phone; }
const std::string &Contact::getSecret() const { return _secret; }

bool Contact::isEmpty() const
{
	return _firstName.empty() && _lastName.empty() && _nickname.empty() && _phone.empty() && _secret.empty();
}
