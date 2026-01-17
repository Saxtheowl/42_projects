# CPP Module 05

Statut : DONE

Derniere mise a jour (2026-01-17 02:25:00) : passage DONE (tests OK).

## Synthèse
Exercices sur les exceptions et la hiérarchie Bureaucrat/Formulaire. ex00→ex03 couvrent création d'un Bureaucrat avec grade borné, formulaires signables/exécutables avec niveaux de grade, et spécialisation de formulaires (Shrubbery/Pardon/Robotomy) avec exécution via Bureaucrat.

## Exercices
- ex00 : Bureaucrat (nom + grade 1..150) avec exceptions GradeTooHigh/Low, opérateur <<.
- ex01 : Form (nom, signé?, grades sign/exec) et interaction avec Bureaucrat::signForm.
- ex02 : Form devient abstrait, formes concrètes ShrubberyCreation, RobotomyRequest, PresidentialPardon (execute, sign grade requis), arbre ASCII.
- ex03 : Intern crée des formulaires (factory), Bureaucrat signe/exécute via polymorphisme.

## Organisation
- `docs/Module_05.pdf` : sujet officiel.
- `ex00`→`ex03` : un dossier par exercice (Makefiles c++98, classes correspondantes).
- Compilation : `c++ -Wall -Wextra -Werror -std=c++98`.

## Avancement
- [x] Sujet copié, README/PLAN init, arborescence à créer.
- [x] ex00 : Bureaucrat (grades bornés + exceptions) implémenté et compilé.
- [x] ex01 : Form (signature + interaction Bureaucrat) implémenté et compilé.
- [x] ex02 : AForm abstrait + formulaires Shrubbery/Robotomy/Pardon (grades sign/exec, ASCII tree, robotomy aléatoire, pardon) compilés.
- [x] ex03 : Intern factory (makeForm) + Bureaucrat sign/execute sur les trois formulaires compilés.

Mise à jour (2025-12-06 00:09:36) : ex02/ex03 implémentés et `make` OK (forms).

## Notes
- Exceptions demandées (std::exception dérivées), pas de STL containers avancés.
- Respect des grades 1 (haut) à 150 (bas), opérateur d'insertion pour affichage.
