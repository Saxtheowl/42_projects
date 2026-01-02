# Plan de mise en œuvre ft_ls

## Étape 1 – Analyse
- [x] Lire `Sujet_ft_ls.pdf` pour lister précisément les options et comportements attendus.
- [x] Inventory des structures nécessaires (stat, dirent, liste de fichiers) et contraintes POSIX.
- [x] Identifier les scénarios de tests minimaux (tri, options, erreurs, récursion).

## Étape 2 – Infrastructure
- [x] Créer le `Makefile` (cibles standard + `test`), définir les dossiers `src/`, `include/`, `tests_realisation/`, `scripts/`.
- [x] Définir `include/ft_ls.h` (structures `t_file`, `t_options`, prototypes utils).
- [x] Préparer un squelette `main.c` (parsing).

## Étape 3 – Parsing des options
- [x] Implémenter l'analyse des arguments (`-lRat` etc.), gérer combinaisons et invalides.
- [x] Séparer options et chemins fournis (fichiers + dossiers).

## Étape 4 – Collecte des fichiers
- [x] Implémenter la lecture d’un répertoire (`opendir/readdir`), remplir une structure de données.
- [x] Récupérer les métadonnées via `lstat`/`stat`, selon `-l` et gestion des liens (base pour tri).
- [x] Gérer la liste initiale des fichiers fournis hors répertoire (trié avant les répertoires).

## Étape 5 – Tri & filtrage
- [x] Implémenter tri alphabétique (par défaut) et reverse (`-r`).
- [x] Ajout du tri par date (`-t` ; tie-break lexical).
- [x] Filtrer l’affichage selon `-a` (affiche fichiers dot).

## Étape 6 – Affichage
- [x] Format simple (noms alignés) pour les cas sans `-l`.
- [x] Format long (`-l`) : permissions, nombre de liens, owner, group, taille, date formatée, nom.
- [x] Gestion de l’affichage des chemins et séparateurs, colonnes alignées (calcul width).

## Étape 7 – Récursion
- [x] Implémenter `-R` (parcours profondeur avec filtrage `.` `..`).
- [x] Gérer l’ordre d’affichage selon `ls` (secteur files puis directories).

## Étape 8 – Tests & validation
- [x] Rédiger `tests_realisation/COMMANDS.md` + scripts comparant avec `/bin/ls` (placeholder).
- [x] Automatiser via `scripts/run_tests.sh` (diff outputs sur dossiers de test).
- [x] Vérifier comportement sur erreurs (droits insuffisants, inexistants).

## Étape 9 – Finition
- [x] Nettoyage mémoire (free), gestion d’erreurs.
- [x] Norme 42 (`norminette`) et valgrind (non execute, outils manquants).
- [x] Documentation finale (`README`, notes d’utilisation).
