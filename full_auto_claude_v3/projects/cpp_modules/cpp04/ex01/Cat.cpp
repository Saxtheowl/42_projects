/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Cat.cpp                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Cat.hpp"

Cat::Cat(void) : Animal() { _type = "Cat"; _brain = new Brain(); std::cout << "Cat constructor called" << std::endl; }

Cat::Cat(const Cat& other) : Animal(other) {
	_brain = new Brain(*other._brain);
	std::cout << "Cat copy constructor called" << std::endl;
}

Cat& Cat::operator=(const Cat& other) {
	if (this != &other) { Animal::operator=(other); delete _brain; _brain = new Brain(*other._brain); }
	return (*this);
}

Cat::~Cat(void) { delete _brain; std::cout << "Cat destructor called" << std::endl; }

void Cat::makeSound(void) const { std::cout << "Meow! Meow!" << std::endl; }
Brain* Cat::getBrain(void) const { return (_brain); }
