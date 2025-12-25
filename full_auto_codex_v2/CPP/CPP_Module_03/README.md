# CPP Module 03

## Synthèse
Module dédié à l'héritage. Exercices ex00→ex03 : ClapTrap de base, variantes FragTrap/ScavTrap/ClapTrap hiérarchisés, gestion des méthodes d'attaque/gate keeper/high fives, et règles de copie/constructeurs.

## Exercices (sujets)
- ex00 : ClapTrap (HP/EP/AD) avec constructeurs, attack/takeDamage/beRepaired.
- ex01 : ScavTrap héritant de ClapTrap, mode Gate keeper.
- ex02 : FragTrap héritant de ClapTrap, highFivesGuys.
- ex03 : DiamondTrap héritant de ScavTrap et FragTrap (diamant), méthode whoAmI.

## Organisation
- `docs/Module_03.pdf` : sujet officiel.
- `ex00`→`ex03` : un dossier par exercice (Makefile + classes correspondantes).
- Compilation : `c++ -Wall -Wextra -Werror -std=c++98` (clang++ autorisé, flags idem).

## Avancement
- [x] Sujet copié, README/PLAN init, arborescence posée.
- [x] Implémentations ex00→ex03 (ClapTrap/ScavTrap/FragTrap/DiamondTrap) avec Makefiles c++98.
- [ ] Vérifier sorties conformes au sujet (tests additionnels à ajouter si besoin).

## Notes
- Pas de STL containers/algorithm (jusqu'au module 08), pas de `using namespace std`.
- Forme coplienne à respecter sur les classes dérivées.
