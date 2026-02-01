/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "easyfind.hpp"
#include <iostream>
#include <vector>
#include <list>

int	main(void)
{
	std::vector<int> vec;
	for (int i = 0; i < 10; i++) vec.push_back(i * 2);

	try {
		std::vector<int>::iterator it = easyfind(vec, 8);
		std::cout << "Found: " << *it << std::endl;
	} catch (std::exception& e) { std::cout << e.what() << std::endl; }

	try {
		std::vector<int>::iterator it = easyfind(vec, 7);
		std::cout << "Found: " << *it << std::endl;
	} catch (std::exception& e) { std::cout << e.what() << std::endl; }

	std::list<int> lst;
	for (int i = 0; i < 5; i++) lst.push_back(i + 100);
	try {
		std::list<int>::iterator it = easyfind(lst, 102);
		std::cout << "Found in list: " << *it << std::endl;
	} catch (std::exception& e) { std::cout << e.what() << std::endl; }

	return (0);
}
