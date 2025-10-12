i il faut prendre une decision, prend la meilleur, refere toi aux premieres instructions que je t'ai donné et dans tous les cas continue le projet

# Computor v1

## Synthèse
- Résolution d’équations polynomiales de degré ≤ 2 en ligne de commande.
- Prend une équation au format `a * X^p ± ... = b * X^q ± ...`, la réduit à 0 puis en affiche le degré.
- Calcule les solutions réelles ou complexes selon le signe du discriminant et gère les cas dégénérés (degré 0 ou 1).

## Étapes principales
- Normalisation et parsing de l’équation en coefficients pondérés par exposant, déplacement des termes sur le membre gauche.
- Affichage de la forme réduite complète avec les coefficients pour chaque puissance rencontrée.
- Résolution analytique des degrés 0, 1 et 2 (discriminant positif/nul/négatif).

## Compilation
```sh
make
```
- Génère le binaire `computor`.

## Utilisation
```sh
./computor "5 * X^0 + 4 * X^1 - 9.3 * X^2 = 1 * X^0"
```
- Affiche la forme réduite, le degré et les solutions.

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Compile le projet, lance plusieurs cas (degré 2, degré 1, cas sans solution) et vérifie les sorties clés.
