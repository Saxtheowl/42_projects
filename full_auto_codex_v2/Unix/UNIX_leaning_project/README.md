# ft_select

## Synthèse
Interface terminale interactive inspirée du sujet *ft_select* : le programme affiche les arguments fournis, permet de naviguer au clavier (flèches), de sélectionner/désélectionner (`SPACE`), d’effacer (`DEL`/`BACKSPACE`) et de valider (`ENTER`). Les sélections sont renvoyées sur la sortie standard, séparées par des espaces, afin d’être réutilisables dans des scripts shell.

## Architecture & approche
- `src/app.c` : initialisation/cleanup du terminal (termios), chargement des termcaps, gestion de l’affichage en colonnes et de l’état global.
- `src/input.c` : lecture brute des touches (escape sequences), déplacements du curseur, suppression et sélection.
- `src/signals.c` : gestion de `SIGWINCH`, `SIGTSTP`, `SIGCONT`, interruption propre et restauration du terminal.
- `inc/ft_select.h` : structures de données (`t_app`, `t_item`), prototypes partagés.
- `Makefile` : compilation via `-ltermcap`.
- `tests_realisation/` : tests Python simulant une session utilisateur via pseudo-terminal.

Points clés :
- Terminal forcé en mode raw (sans écho), restauration systématique (même après signaux).
- Mise à jour dynamique lors d’un redimensionnement (`SIGWINCH`).
- Navigation circulaire, listes multi-colonnes, suppression d’éléments, sortie `ESC` sans impression.

## Compilation & utilisation
```bash
make
./ft_select item1 item2 item3
```
Contrôles :
- Flèches : déplacement
- `SPACE` : (dé)sélection
- `DEL` / `BACKSPACE` : suppression de l’entrée courante
- `ENTER` : renvoie les choix sélectionnés et quitte
- `ESC` ou `q` : sortie sans sélection

## Tests
- `python3 tests_realisation/test_ft_select.py` : compile et vérifie les scénarios interactifs de base via un pseudo-terminal (sélection simple, sortie par `ESC`).

## Répartition des PDF
- `Sujet` : `organized_subjects/Unix/UNIX_leaning_project.pdf`
