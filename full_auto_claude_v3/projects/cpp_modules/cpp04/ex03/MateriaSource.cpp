/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   MateriaSource.cpp                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: claude <claude@anthropic.com>              +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2024/01/01 00:00:00 by claude            #+#    #+#             */
/*   Updated: 2024/01/01 00:00:00 by claude           ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "MateriaSource.hpp"

MateriaSource::MateriaSource(void) { for (int i = 0; i < 4; i++) _templates[i] = NULL; }

MateriaSource::MateriaSource(const MateriaSource& other) {
	for (int i = 0; i < 4; i++) {
		if (other._templates[i]) _templates[i] = other._templates[i]->clone();
		else _templates[i] = NULL;
	}
}

MateriaSource& MateriaSource::operator=(const MateriaSource& other) {
	if (this != &other) {
		for (int i = 0; i < 4; i++) { delete _templates[i]; _templates[i] = NULL; }
		for (int i = 0; i < 4; i++) {
			if (other._templates[i]) _templates[i] = other._templates[i]->clone();
		}
	}
	return (*this);
}

MateriaSource::~MateriaSource(void) { for (int i = 0; i < 4; i++) delete _templates[i]; }

void MateriaSource::learnMateria(AMateria* m) {
	if (!m) return;
	for (int i = 0; i < 4; i++) {
		if (!_templates[i]) { _templates[i] = m; return; }
	}
	delete m;
}

AMateria* MateriaSource::createMateria(std::string const& type) {
	for (int i = 0; i < 4; i++) {
		if (_templates[i] && _templates[i]->getType() == type)
			return (_templates[i]->clone());
	}
	return (NULL);
}
