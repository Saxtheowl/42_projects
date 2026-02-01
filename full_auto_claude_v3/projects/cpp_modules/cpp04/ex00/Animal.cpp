/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Animal.cpp                                         :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Animal.hpp"

Animal::Animal(void) : _type("Animal")
{ std::cout << "Animal default constructor called" << std::endl; }

Animal::Animal(const Animal& other) : _type(other._type)
{ std::cout << "Animal copy constructor called" << std::endl; }

Animal& Animal::operator=(const Animal& other) { if (this != &other) _type = other._type; return (*this); }

Animal::~Animal(void) { std::cout << "Animal destructor called" << std::endl; }

std::string Animal::getType(void) const { return (_type); }

void Animal::makeSound(void) const { std::cout << "* generic animal sound *" << std::endl; }
