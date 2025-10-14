/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   MateriaSource.cpp                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "MateriaSource.hpp"

MateriaSource::MateriaSource()
{
	for (int i = 0; i < 4; i++)
		this->templates[i] = NULL;
}

MateriaSource::MateriaSource(const MateriaSource& other)
{
	for (int i = 0; i < 4; i++)
	{
		if (other.templates[i])
			this->templates[i] = other.templates[i]->clone();
		else
			this->templates[i] = NULL;
	}
}

MateriaSource& MateriaSource::operator=(const MateriaSource& other)
{
	if (this != &other)
	{
		// Delete old templates
		for (int i = 0; i < 4; i++)
		{
			if (this->templates[i])
				delete this->templates[i];
			this->templates[i] = NULL;
		}
		// Deep copy new templates
		for (int i = 0; i < 4; i++)
		{
			if (other.templates[i])
				this->templates[i] = other.templates[i]->clone();
		}
	}
	return (*this);
}

MateriaSource::~MateriaSource()
{
	for (int i = 0; i < 4; i++)
	{
		if (this->templates[i])
			delete this->templates[i];
	}
}

void MateriaSource::learnMateria(AMateria* m)
{
	if (!m)
		return;

	for (int i = 0; i < 4; i++)
	{
		if (!this->templates[i])
		{
			this->templates[i] = m->clone();
			return;
		}
	}
	// Already know 4 materias, don't learn
}

AMateria* MateriaSource::createMateria(std::string const & type)
{
	for (int i = 0; i < 4; i++)
	{
		if (this->templates[i] && this->templates[i]->getType() == type)
			return (this->templates[i]->clone());
	}
	return (NULL);  // Unknown type
}
