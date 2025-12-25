# Plan CPP Module 05

## Étape 1 – Lecture
- [x] Copier le sujet (`docs/Module_05.pdf`) et lister ex00→ex03.

## Étape 2 – Squelettes
- [x] Créer arborescence `ex00`..`ex03` avec Makefiles c++98, classes Bureaucrat/Form et dérivées (Shrubbery/Robotomy/Pardon) + Intern.

## Étape 3 – Implémentations
- [x] ex00 : Bureaucrat (grade borné, exceptions, opérateur<<).
- [x] ex01 : Form (signing) + interaction Bureaucrat::signForm.
- [x] ex02 : Form abstrait + formulaires concrets (execute, sign/exec grades, arbre ASCII, robotomy rand, pardon).
- [x] ex03 : Intern factory (makeForm), Bureaucrat signe/exécute.

## Étape 4 – Tests
- [x] Mains d'exemple compilées (`make` ex02/ex03), cas limites grade/unknown form couverts par les try/catch.

## Étape 5 – Documentation
- [x] Mettre à jour README avec l'avancement et usages.

Journal (2025-12-06 00:09:36) : ex02/ex03 codés (AForm + Shrubbery/Robotomy/Pardon + Intern), builds `make` OK.
