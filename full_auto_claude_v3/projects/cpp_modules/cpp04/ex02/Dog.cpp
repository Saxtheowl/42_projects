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

Dog::Dog(void) : AAnimal() { _type = "Dog"; _brain = new Brain(); std::cout << "Dog constructor called" << std::endl; }
Dog::Dog(const Dog& other) : AAnimal(other) { _brain = new Brain(*other._brain); std::cout << "Dog copy constructor called" << std::endl; }
Dog& Dog::operator=(const Dog& other) { if (this != &other) { AAnimal::operator=(other); delete _brain; _brain = new Brain(*other._brain); } return (*this); }
Dog::~Dog(void) { delete _brain; std::cout << "Dog destructor called" << std::endl; }
void Dog::makeSound(void) const { std::cout << "Woof! Woof!" << std::endl; }
