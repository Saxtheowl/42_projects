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

#include "iter.hpp"
#include <iostream>

template<typename T>
void print(const T& x) { std::cout << x << " "; }

template<typename T>
void increment(T& x) { x++; }

int	main(void)
{
	int arr[] = {1, 2, 3, 4, 5};
	std::cout << "Before: "; iter(arr, 5, print<int>); std::cout << std::endl;
	iter(arr, 5, increment<int>);
	std::cout << "After: "; iter(arr, 5, print<int>); std::cout << std::endl;

	std::string strs[] = {"hello", "world", "42"};
	std::cout << "Strings: "; iter(strs, 3, print<std::string>); std::cout << std::endl;

	return (0);
}
