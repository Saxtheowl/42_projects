/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Dog.cpp                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Dog.hpp"

Dog::Dog(void) : Animal() { _type = "Dog"; std::cout << "Dog constructor called" << std::endl; }

Dog::Dog(const Dog& other) : Animal(other) { std::cout << "Dog copy constructor called" << std::endl; }

Dog& Dog::operator=(const Dog& other) { Animal::operator=(other); return (*this); }

Dog::~Dog(void) { std::cout << "Dog destructor called" << std::endl; }

void Dog::makeSound(void) const { std::cout << "Woof! Woof!" << std::endl; }
