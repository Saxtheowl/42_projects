# CPP Module 01

## Synthèse
Module consacré aux pointeurs sur membres, références, allocation/stack vs heap et `switch`. Exercices ex00 → ex06 couvrent zombis sur stack/heap, allocation massive, pointeurs/références, armes et human, mini-sed, logging (`Harl`), et filtrage de logs.

## Exercices
- ex00 BraiiiiiiinnnzzzZ: classe Zombie, alloc stack et heap, `newZombie`/`randomChump`.
- ex01 Moar brainz!: horde de zombies allouée via `zombieHorde`, N >= 0.
- ex02 HI THIS IS BRAIN: manip références vs pointeur sur `std::string` + affichage.
- ex03 Unnecessary violence: classes `Weapon`, `HumanA`, `HumanB`, changement d'arme.
- ex04 Sed is for losers: mini `sed` (remplacer s1 par s2) avec fichiers.<replace>.<name>.
- ex05 Harl 2.0: `switch`-like avec niveaux de logs (`DEBUG`/`INFO`/`WARNING`/`ERROR`).
- ex06 Harl filter: filtrer les logs à partir d'un niveau passé en arg.

## Organisation
- `docs/Module_01.pdf` : sujet officiel.
- `ex00` → `ex06` : un dossier par exercice (Makefile + sources à créer).
- Compilation : `c++ -Wall -Wextra -Werror -std=c++98`.

## Avancement
- [x] ex00 → ex06 implémentés avec Makefiles c++98 (tests locaux OK).

## Notes
- Interdits : `printf`/`malloc`/`free`, `using namespace std`.
- Préférer std::string, flux iostream, pas de Boost/C++11.
