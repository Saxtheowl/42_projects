# ft_helpme

Statut : DONE

Dernière mise à jour (2026-01-17 03:15:36) : ajout tests sur valeurs par défaut (unspecified), run_tests OK.

Dernière mise à jour (2025-12-26 04:45:00) : ajout de la sortie Markdown (`-m`) et de l’écriture directe dans un fichier (`-o path`) en plus du template texte enrichi (expected/actual, logs/repro), toujours paramétrable (projet/question/contexte) et testé.

## Build & tests
```bash
make
make test   # lance tests_realisation/run_tests.sh
```

## Usage
```bash
./ft_helpme [-p project] [-q question] [-c context] [-m] [-o file]
```
- Génère un template prêt à poster (inclut timestamp).
- Valeurs par défaut : “unspecified” si non fournie.
- `-m` : sortie Markdown (headings, listes) pour copier/coller dans un dépôt ou un ticket qui rend le Markdown.
- `-o file` : écrit le template dans `file` (sinon stdout).

## Exemple
```
./ft_helpme -p "libft" -q "Pourquoi segfault sur buffer vide ?" -c "Lecture stdin, calloc, write"      # texte
./ft_helpme -m -p "libft" -q "Pourquoi segfault sur buffer vide ?" -c "Lecture stdin, calloc, write"  # markdown
./ft_helpme -o help.md -m -p "libft" -q "Pourquoi segfault sur buffer vide ?" -c "Lecture stdin, calloc, write"  # markdown en fichier
```

Sortie : sections prêtes à remplir (What I tried, expected/actual, logs/repro).
