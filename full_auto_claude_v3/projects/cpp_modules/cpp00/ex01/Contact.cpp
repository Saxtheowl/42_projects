/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Contact.cpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Contact.hpp"

Contact::Contact(void) {}

Contact::~Contact(void) {}

void	Contact::setFirstName(std::string firstName) { _firstName = firstName; }
void	Contact::setLastName(std::string lastName) { _lastName = lastName; }
void	Contact::setNickname(std::string nickname) { _nickname = nickname; }
void	Contact::setPhoneNumber(std::string phoneNumber) { _phoneNumber = phoneNumber; }
void	Contact::setDarkestSecret(std::string darkestSecret) { _darkestSecret = darkestSecret; }

std::string	Contact::getFirstName(void) const { return (_firstName); }
std::string	Contact::getLastName(void) const { return (_lastName); }
std::string	Contact::getNickname(void) const { return (_nickname); }
std::string	Contact::getPhoneNumber(void) const { return (_phoneNumber); }
std::string	Contact::getDarkestSecret(void) const { return (_darkestSecret); }

bool	Contact::isEmpty(void) const
{
	return (_firstName.empty() && _lastName.empty() && _nickname.empty()
		&& _phoneNumber.empty() && _darkestSecret.empty());
}
