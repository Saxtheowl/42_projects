# so_long

## Synthèse
Implémentation complète du projet `so_long` : chargement d’une carte `.ber`, validations renforcées (rectangularité, murs, accessibilité par BFS), rendu graphique via MiniLibX avec sprites personnalisés, gestion du joueur (WASD/flèches), collecte des items, ouverture de la sortie et fin de partie propre (fermeture fenêtre/ESC). Un mode « headless » (`make MLX=0`) reste disponible pour les environnements dépourvus de MiniLibX afin de conserver une exécution/test automatisé.

## Architecture
- `inc/so_long.h` : structures `t_map`, `t_game`, textures, prototypes publics.
- `src/map.c` : lecture fichier, split ligne par ligne, comptage éléments (`P/E/C`), stockage position joueur.
- `src/validate.c` : contrôles de forme + BFS pour s’assurer que tous les collectibles et la sortie sont atteignables.
- `src/graphics.c` : initialisation MiniLibX, chargement sprites (XPM), rendu de la map et du HUD, gestion des inputs (WASD/flèches, ESC), boucle d’événements.
- `src/graphics_stub.c` : implémentation minimale utilisée via `make MLX=0` (pas de fenêtre, utile pour CI/tests).
- `src/utils.c` : fonctions de base (strlen, strdup, join, split lignes, I/O texte).
- `assets/textures/*.xpm` : sprites 32×32 (mur, sol, joueur, collectible, sortie fermée/ouverte).
- `assets/maps/level1.ber` : exemple de carte valide.
- `tests_realisation/run_tests.sh` : compilation en mode headless + scénarios de validation parsing/BFS.

## Compilation & exécution
### Avec rendu graphique (recommandé)
Installer les dépendances MiniLibX (exemple Debian/Ubuntu) :
```bash
sudo apt-get install -y build-essential libx11-dev libxext-dev libbsd-dev zlib1g-dev
```
Puis :
```bash
make          # construit MiniLibX + le binaire
./so_long assets/maps/level1.ber
```

### Mode headless (environnement sans X11)
```bash
make MLX=0
./so_long assets/maps/level1.ber
```
Le programme reste fonctionnel (chargement + validations) et affiche des messages avertissant que le rendu est désactivé.

## Tests
```bash
./tests_realisation/run_tests.sh
```
Le script compile avec `make MLX=0`, exécute un cas nominal et plusieurs cartes invalides (murs, accessibilité). Les tests peuvent être enrichis en ajoutant d’autres cartes dans `tests_realisation`.

## PDF
- `Sujet_So_Long.pdf` : consignes officielles du projet (module principal).
