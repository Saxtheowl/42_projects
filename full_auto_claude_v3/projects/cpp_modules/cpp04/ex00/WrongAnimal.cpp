/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   WrongAnimal.cpp                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "WrongAnimal.hpp"

WrongAnimal::WrongAnimal(void) : _type("WrongAnimal")
{ std::cout << "WrongAnimal constructor called" << std::endl; }

WrongAnimal::WrongAnimal(const WrongAnimal& other) : _type(other._type) {}

WrongAnimal& WrongAnimal::operator=(const WrongAnimal& other) { if (this != &other) _type = other._type; return (*this); }

WrongAnimal::~WrongAnimal(void) { std::cout << "WrongAnimal destructor called" << std::endl; }

std::string WrongAnimal::getType(void) const { return (_type); }

void WrongAnimal::makeSound(void) const { std::cout << "* wrong animal sound *" << std::endl; }
