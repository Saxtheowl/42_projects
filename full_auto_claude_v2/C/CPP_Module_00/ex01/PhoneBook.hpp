/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   PhoneBook.hpp                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PHONEBOOK_HPP
# define PHONEBOOK_HPP

# include "Contact.hpp"
# include <iomanip>

class PhoneBook
{
private:
	Contact	contacts[8];
	int		currentIndex;
	int		contactCount;

	std::string	truncate(const std::string& str, size_t width) const;
	void		displayHeader() const;
	void		displayContactRow(int index) const;

public:
	PhoneBook();
	~PhoneBook();

	void	addContact();
	void	searchContact() const;
};

#endif
