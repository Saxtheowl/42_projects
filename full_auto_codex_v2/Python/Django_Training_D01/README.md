# Django Training D01

Statut : DONE

Derniere mise a jour (2026-01-16 22:09:50) : passage DONE (tests OK).

## Synthèse
Jour 01 de la piscine Python/Django : exercices fondamentaux en Python (variables, dictionnaires, parsing de fichiers, détection état/capitale) et génération d'une page HTML représentant la table périodique. Les scripts sont autonomes et vivent dans `ex00` → `ex07`. Le scaffold Django initial reste présent mais n'est pas utilisé pour ces exercices.

## Plan
- Consignes dans `docs/D01_-_Python-Django_training.pdf`.
- Scripts :
  - `ex00/var.py` : affichage de 9 variables typées.
  - `ex01/numbers.py` : lecture de `numbers.txt` (1 à 100 séparés par des virgules).
  - `ex02/var_to_dict.py` : inversion liste de tuples → dict et affichage.
  - `ex03/capital_city.py` : capitale depuis un état (arg unique sinon silence).
  - `ex04/state.py` : état depuis une capitale (arg unique sinon silence).
  - `ex05/all_in.py` : détection état/capitale insensible à la casse/espaces (silence si virgules consécutives).
  - `ex06/my_sort.py` : tri par année puis nom.
  - `ex07/periodic_table.py` : génère `periodic_table.html` depuis `periodic_table.txt`.

## Environnement
- Python 3.x (aucune dépendance externe requise pour les exercices).
- Un `requirements.txt` Django subsiste pour les journées suivantes ; il n'est pas nécessaire ici.

## Avancement
- PDF lu et exercices ex00 → ex07 implémentés.
- Ressources générées : `ex01/numbers.txt` (1..100), `ex07/periodic_table.txt` (119 éléments via dataset JSON Bowserinator).

## Utilisation rapide
```bash
# Exemple ex05
cd ex05
python3 all_in.py "New jersey, Trenton, Salem"

# Générer la table périodique (fichier HTML à ouvrir dans un navigateur)
cd ex07
python3 periodic_table.py
```

## Tests
```bash
./scripts/run_tests.sh
```

## Journal
- 2025-12-04 16:43:00 : Implémentation complète ex00 → ex07, génération des ressources (numbers/periodic_table), tests manuels OK, README/PLAN mis à jour.
- 2026-01-16 22:02:10 : Ajout smoke tests automatises + run_tests OK.
- 2026-01-16 22:04:51 : Ajout section Tests dans le README.
- 2026-01-16 22:09:50 : Passage DONE apres validation tests.
