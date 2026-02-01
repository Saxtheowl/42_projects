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

#include "Serializer.hpp"

int	main(void)
{
	Data data; data.value = 42; data.name = "test";
	std::cout << "Original ptr: " << &data << std::endl;
	std::cout << "Value: " << data.value << ", Name: " << data.name << std::endl;

	uintptr_t raw = Serializer::serialize(&data);
	std::cout << "Serialized: " << raw << std::endl;

	Data* ptr = Serializer::deserialize(raw);
	std::cout << "Deserialized ptr: " << ptr << std::endl;
	std::cout << "Value: " << ptr->value << ", Name: " << ptr->name << std::endl;

	std::cout << "Same pointer: " << (ptr == &data ? "yes" : "no") << std::endl;
	return (0);
}
