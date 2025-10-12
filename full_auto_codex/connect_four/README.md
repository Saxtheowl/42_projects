# Connect Four

## Synthèse
- Jeu Puissance 4 en C++98 fonctionnant en mode texte (humain vs humain ou humain vs IA simple).
- Grille 6x7 standard, contrôle des victoires, détection des égalités, redémarrage rapide.
- IA heuristique : cherche un coup gagnant, sinon bloque l’adversaire, sinon privilégie le centre.

## Compilation
```sh
make
```
Produit le binaire `connect_four`.

## Utilisation
```sh
./connect_four
```
Choisir le mode de jeu (vs ordinateur ou non), entrer le numéro de colonne (0-6). Les colonnes pleines ou invalides sont refusées.

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Compile le jeu et exécute un test unitaire vérifiant la détection de victoire et le choix d’un coup gagnant par l’IA.
