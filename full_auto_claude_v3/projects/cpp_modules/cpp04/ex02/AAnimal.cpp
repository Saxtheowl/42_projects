/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   AAnimal.cpp                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "AAnimal.hpp"

AAnimal::AAnimal(void) : _type("AAnimal") { std::cout << "AAnimal constructor called" << std::endl; }
AAnimal::AAnimal(const AAnimal& other) : _type(other._type) { std::cout << "AAnimal copy constructor called" << std::endl; }
AAnimal& AAnimal::operator=(const AAnimal& other) { if (this != &other) _type = other._type; return (*this); }
AAnimal::~AAnimal(void) { std::cout << "AAnimal destructor called" << std::endl; }
std::string AAnimal::getType(void) const { return (_type); }
