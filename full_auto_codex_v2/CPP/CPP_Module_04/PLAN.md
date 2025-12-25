# Plan CPP Module 04

## Étape 1 – Lecture
- [x] Copier le sujet (`docs/Module_04.pdf`) et lister ex00→ex04.

## Étape 2 – Squelettes
- [x] Créer arborescence `ex00`..`ex04` avec Makefiles c++98, classes Animal/Cat/Dog/Brain puis AAnimal, et MateriaSource/Character/Ice/Cure.

## Étape 3 – Implémentations
- [x] ex00 : Animal (base, virtual makeSound), Cat/Dog dérivés.
- [x] ex01 : Ajouter Brain (deep copy) à Cat/Dog, vérifier destruction/copie.
- [x] ex02 : AAnimal abstrait (makeSound pure), Cat/Dog/Brain idem ex01.
- [x] ex03 : Materia (AMateria/Ice/Cure), IMateriaSource/MateriaSource, ICharacter/Character (inventaire 4, clone/use).
- [ ] ex04 : Suite AFK Mining (selon sujet) — maintenir interfaces.

## Étape 4 – Tests
- [x] Reproduire les mains du sujet, tester copies/destroy (Brain), gestion slots (Materia).

## Étape 5 – Documentation
- [ ] Mettre à jour README avec l'avancement et commandes.
