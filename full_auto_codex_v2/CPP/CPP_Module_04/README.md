# CPP Module 04

Statut : DONE

Derniere mise a jour (2026-01-17 02:15:13) : passage DONE (tests OK).

## Synthèse
Polymorphisme de sous-type, classes abstraites et interfaces. Exercices ex00→ex04 : polymorphisme Animal/Cat/Dog avec deep copy pour Brain, gestion Materia (AMateria/Ice/Cure, MateriaSource, Character), et vérifications de copie/destruction.

## Exercices (résumé)
- ex00 : Animal (classe de base), Cat/Dog dérivés (makeSound), interdit Animal instanciation directe.
- ex01 : Ajout Brain (deep copy) dans Cat/Dog (tableau d'idées).
- ex02 : Classe abstraite AAnimal, mêmes dérivés Cat/Dog (virtual pure makeSound).
- ex03 : Materia (AMateria, Ice, Cure), MateriaSource, Character (slots 4), clone/use.
- ex04 : Interface ICharacter/Ice/Cure (suite Materia) — selon PDF (AFK Mining).

## Organisation
- `docs/Module_04.pdf` : sujet officiel.
- Dossiers `ex00`→`ex04` à créer (Makefiles c++98, classes/headers).
- Compilation : `c++ -Wall -Wextra -Werror -std=c++98`.

## Avancement
- [x] Sujet copié, README/PLAN init, arbo posée.
- [x] ex00 : Animal/Cat/Dog (polymorphisme de base) implémenté et compilé.
- [x] ex01 : Animal/Cat/Dog avec Brain (deep copy) implémenté et compilé.
- [x] ex02 : AAnimal abstrait + Cat/Dog/Brain implémentés (deep copy) et compilés.
- [x] ex03 : Materia (AMateria/Ice/Cure, MateriaSource, Character) implémenté et compilé.
- [x] ex04 : AFK Mining (Materia suite) implémenté et compilé (réutilise interfaces/construction ex03).

## Notes
- Pas de STL containers/algorithm (avant module 08), pas de `using namespace std`.
- Coplien form obligatoire, attention au deep copy et à la règle des trois.
