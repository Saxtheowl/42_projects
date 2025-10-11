# 2048 – Jeu console en C

## Synthèse
- Reproduction du jeu 2048 pour le terminal avec `ncurses`.
- Plateau 4×4, génération pseudo-aléatoire des tuiles (2 plus fréquentes que 4).
- Gestion complète des déplacements, fusions, score et détection de victoire (`WIN_VALUE` = 2048).
- Affichage dynamique avec couleurs (si disponibles) et messages de statut; possibilité de continuer après avoir atteint 2048.
- Clavier : flèches pour jouer, `ESC` ou `q` pour quitter, `r` pour relancer après un blocage.

## Étapes principales
- Initialisation du moteur de jeu (`game.c`) : plateau, génération des tuiles, logique de fusion et détection des mouvements disponibles.
- Boucle d’interface (`main.c`) : configuration de `ncurses`, rendu de la grille centrée, prise en compte du redimensionnement et des entrées clavier.
- Mise en place de tests unitaires C (sans interface) pour valider la logique du plateau et du score.

## Compilation
```sh
make
```
- Produit le binaire `./2048`.
- Dépend de la bibliothèque `ncurses` et d’un compilateur C compatible 42 (`cc` avec `-Wall -Wextra -Werror`).

## Exécution
```sh
./2048
```
- Utiliser les flèches pour déplacer les tuiles.
- `ESC` ou `q` : quitter proprement.
- `r` : redémarrer la partie lorsqu’aucun coup n’est possible.

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Compile un exécutable dédié dans `tests_realisation/` et vérifie les cas de fusion, de blocage et la levée du drapeau de victoire.
- Les commandes et leur description sont récapitulées dans `tests_realisation/COMMANDES.md`.
