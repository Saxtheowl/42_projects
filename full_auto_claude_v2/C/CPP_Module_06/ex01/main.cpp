/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Serializer.hpp"
#include <iostream>

int main()
{
	Data original;
	original.id = 42;
	original.name = "Test Data";
	original.value = 3.14159;

	std::cout << "=== Original Data ===" << std::endl;
	std::cout << "Address: " << &original << std::endl;
	std::cout << "ID: " << original.id << std::endl;
	std::cout << "Name: " << original.name << std::endl;
	std::cout << "Value: " << original.value << std::endl;

	std::cout << "\n=== Serialization ===" << std::endl;
	uintptr_t serialized = Serializer::serialize(&original);
	std::cout << "Serialized value: " << serialized << std::endl;

	std::cout << "\n=== Deserialization ===" << std::endl;
	Data* deserialized = Serializer::deserialize(serialized);
	std::cout << "Deserialized address: " << deserialized << std::endl;
	std::cout << "ID: " << deserialized->id << std::endl;
	std::cout << "Name: " << deserialized->name << std::endl;
	std::cout << "Value: " << deserialized->value << std::endl;

	std::cout << "\n=== Verification ===" << std::endl;
	if (deserialized == &original)
		std::cout << "SUCCESS: Pointers match!" << std::endl;
	else
		std::cout << "FAIL: Pointers don't match!" << std::endl;

	if (deserialized->id == original.id &&
		deserialized->name == original.name &&
		deserialized->value == original.value)
		std::cout << "SUCCESS: Data matches!" << std::endl;
	else
		std::cout << "FAIL: Data doesn't match!" << std::endl;

	return (0);
}
