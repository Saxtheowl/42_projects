# CPP Module 02

## Synthèse
Polymorphisme ad-hoc, surcharge d'opérateurs et forme canonique orthodoxe. Exercices ex00→ex03 : classe fixe (coplien), nombre à virgule fixe avec overloads, conversions et comparaisons, fonctions min/max, et calcul de point-in-triangle (BSP).

## Exercices
- ex00 : Classe Fixed (forme canonique orthodoxe, getters/setters basiques).
- ex01 : Fixed amélioré (constructeurs float/int, toFloat/toInt, surcharge `<<`).
- ex02 : Fixed avec opérateurs arithmétiques/comparaison/incrément, `min`/`max` statiques.
- ex03 : Implémenter `bsp` (point dans triangle) en utilisant Fixed/Point.

## Organisation
- `docs/Module_02.pdf` : sujet officiel.
- `ex00` → `ex03` : un dossier par exercice (Makefile + sources à créer).
- Compilation : `c++ -Wall -Wextra -Werror -std=c++98`.

## Avancement
- [x] Sujet copié, arborescence posée.
- [x] Implémentations ex00→ex03 avec Makefiles c++98 (tests basiques exécutés).

## Notes
- Pas de `using namespace std`, pas de C++11.
- Respecter la forme coplienne (constructeur défaut/copie, opérateur=, destructeur).
