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

#include "Array.hpp"
#include <iostream>

int	main(void)
{
	Array<int> arr(5);
	for (size_t i = 0; i < arr.size(); i++) arr[i] = i * 2;
	std::cout << "Array: ";
	for (size_t i = 0; i < arr.size(); i++) std::cout << arr[i] << " ";
	std::cout << std::endl;

	Array<int> copy(arr);
	copy[0] = 100;
	std::cout << "Original[0]: " << arr[0] << ", Copy[0]: " << copy[0] << std::endl;

	try { std::cout << arr[10] << std::endl; }
	catch (std::exception& e) { std::cout << "Exception: out of bounds" << std::endl; }

	Array<std::string> strs(3);
	strs[0] = "hello"; strs[1] = "world"; strs[2] = "42";
	for (size_t i = 0; i < strs.size(); i++) std::cout << strs[i] << " ";
	std::cout << std::endl;

	return (0);
}
