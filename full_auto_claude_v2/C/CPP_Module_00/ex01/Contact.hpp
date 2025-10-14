/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Contact.hpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef CONTACT_HPP
# define CONTACT_HPP

# include <string>
# include <iostream>

class Contact
{
private:
	std::string	firstName;
	std::string	lastName;
	std::string	nickname;
	std::string	phoneNumber;
	std::string	darkestSecret;

public:
	Contact();
	~Contact();

	void		setFirstName(const std::string& name);
	void		setLastName(const std::string& name);
	void		setNickname(const std::string& nick);
	void		setPhoneNumber(const std::string& number);
	void		setDarkestSecret(const std::string& secret);

	std::string	getFirstName() const;
	std::string	getLastName() const;
	std::string	getNickname() const;
	std::string	getPhoneNumber() const;
	std::string	getDarkestSecret() const;

	bool		isEmpty() const;
	void		display() const;
};

#endif
