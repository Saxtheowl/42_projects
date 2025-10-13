# ft_nm / ft_otool

## Synthèse
Réimplémentation en C des commandes `nm` (sans options) et `otool -t` pour des binaires Mach-O 64 bits. Le projet fournit deux exécutables `ft_nm` et `ft_otool`, construits selon la norme 42 avec un Makefile principal et une `libft` minimale. Les fichiers sont analysés via `mmap`, et toutes les vérifications de bornes sont effectuées pour éviter les corruptions mémoire.

## Architecture
- `Makefile` : compilation de `ft_nm`, `ft_otool` et de la bibliothèque `libft`.
- `inc/` : entêtes partagés (`common.h`, `macho.h`, `ft_nm.h`, `ft_otool.h`).
- `src/common/` : gestion du mapping mémoire et parsing Mach-O 64 bits.
- `src/nm/` : logique `ft_nm` (tri des symboles, rendu ASCII).
- `src/otool/` : logique `ft_otool` (dump hexadécimal de `__TEXT,__text`).
- `libft/` : mini bibliothèque standard avec son propre Makefile.
- `tests_realisation/` : scripts Python générant un binaire Mach-O factice et validant les sorties.
- `Sujet_A_completely_UNIX_project.pdf` : lien symbolique vers le sujet officiel.

Les limitations connues : prise en charge restreinte à Mach-O 64 bits little-endian (magic `MH_MAGIC_64`). Les fichiers universel (Fat) ou 32 bits ne sont pas encore supportés.

## Compilation & utilisation
```bash
make           # construit ft_nm et ft_otool
./ft_nm file.o # affiche la table des symboles triée
./ft_otool file.o # affiche la section __TEXT,__text en hexadécimal
```

Les deux outils acceptent plusieurs fichiers en arguments (comportement identique aux commandes Apple).

## Tests
- `./tests_realisation/run_tests.sh` : recompilation complète puis tests automatisés (`unittest`). Les tests génèrent un binaire Mach-O minimal et comparent les sorties de `ft_nm` / `ft_otool` aux résultats attendus.

## Répartition des PDF
- `Sujet_A_completely_UNIX_project.pdf` : description complète du projet (ft_nm & ft_otool).
