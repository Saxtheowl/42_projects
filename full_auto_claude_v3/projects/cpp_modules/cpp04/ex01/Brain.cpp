/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   Brain.cpp                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "Brain.hpp"

Brain::Brain(void) { std::cout << "Brain constructor called" << std::endl; }

Brain::Brain(const Brain& other) {
	std::cout << "Brain copy constructor called" << std::endl;
	for (int i = 0; i < 100; i++) _ideas[i] = other._ideas[i];
}

Brain& Brain::operator=(const Brain& other) {
	if (this != &other) for (int i = 0; i < 100; i++) _ideas[i] = other._ideas[i];
	return (*this);
}

Brain::~Brain(void) { std::cout << "Brain destructor called" << std::endl; }

void Brain::setIdea(int index, const std::string& idea) { if (index >= 0 && index < 100) _ideas[index] = idea; }
std::string Brain::getIdea(int index) const { if (index >= 0 && index < 100) return (_ideas[index]); return (""); }
