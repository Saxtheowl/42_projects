/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.cpp                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: automated <automated@42.fr>                +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/10/14 00:00:00 by automated         #+#    #+#             */
/*   Updated: 2025/10/14 00:00:00 by automated        ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "AMateria.hpp"
#include "Ice.hpp"
#include "Cure.hpp"
#include "ICharacter.hpp"
#include "Character.hpp"
#include "IMateriaSource.hpp"
#include "MateriaSource.hpp"

int main()
{
	std::cout << "=== Subject Test ===" << std::endl;
	IMateriaSource* src = new MateriaSource();
	src->learnMateria(new Ice());
	src->learnMateria(new Cure());

	ICharacter* me = new Character("me");

	AMateria* tmp;
	tmp = src->createMateria("ice");
	me->equip(tmp);
	tmp = src->createMateria("cure");
	me->equip(tmp);

	ICharacter* bob = new Character("bob");

	me->use(0, *bob);
	me->use(1, *bob);

	delete bob;
	delete me;
	delete src;

	std::cout << "\n=== Additional Tests ===" << std::endl;

	std::cout << "\n--- Test 1: Full inventory ---" << std::endl;
	Character* hero = new Character("hero");
	MateriaSource* source = new MateriaSource();

	source->learnMateria(new Ice());
	source->learnMateria(new Cure());

	// Fill inventory
	for (int i = 0; i < 5; i++)
	{
		AMateria* mat = source->createMateria((i % 2 == 0) ? "ice" : "cure");
		std::cout << "Equipping slot " << i << ": ";
		hero->equip(mat);
		if (i < 4)
			std::cout << "equipped" << std::endl;
		else
		{
			std::cout << "inventory full, materia not equipped" << std::endl;
			delete mat;  // Must delete because it wasn't equipped
		}
	}

	std::cout << "\n--- Test 2: Using all slots ---" << std::endl;
	Character* target = new Character("target");
	for (int i = 0; i < 4; i++)
	{
		std::cout << "Using slot " << i << ": ";
		hero->use(i, *target);
	}

	std::cout << "\n--- Test 3: Unequip and reuse slot ---" << std::endl;
	AMateria* saved = source->createMateria("ice");
	hero->unequip(1);  // Unequip slot 1 (don't delete!)
	hero->equip(source->createMateria("ice"));
	hero->use(1, *target);
	delete saved;  // Now we can delete the unequipped materia

	std::cout << "\n--- Test 4: Unknown materia type ---" << std::endl;
	AMateria* unknown = source->createMateria("fire");
	if (unknown == NULL)
		std::cout << "Cannot create unknown materia type 'fire'" << std::endl;

	std::cout << "\n--- Test 5: Deep copy of Character ---" << std::endl;
	Character original("original");
	original.equip(source->createMateria("ice"));
	original.equip(source->createMateria("cure"));

	std::cout << "Original uses slot 0: ";
	original.use(0, *target);

	Character copy(original);
	std::cout << "Copy uses slot 0: ";
	copy.use(0, *target);

	std::cout << "\n--- Cleanup ---" << std::endl;
	delete hero;
	delete target;
	delete source;

	return 0;
}
