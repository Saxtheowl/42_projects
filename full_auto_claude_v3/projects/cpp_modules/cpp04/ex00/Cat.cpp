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

Cat::Cat(void) : Animal() { _type = "Cat"; std::cout << "Cat constructor called" << std::endl; }

Cat::Cat(const Cat& other) : Animal(other) { std::cout << "Cat copy constructor called" << std::endl; }

Cat& Cat::operator=(const Cat& other) { Animal::operator=(other); return (*this); }

Cat::~Cat(void) { std::cout << "Cat destructor called" << std::endl; }

void Cat::makeSound(void) const { std::cout << "Meow! Meow!" << std::endl; }
