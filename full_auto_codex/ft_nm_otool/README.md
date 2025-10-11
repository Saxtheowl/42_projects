# ft_nm & ft_otool – analyse ELF 64 bits

## Synthèse
- `ft_nm` re-liste les symboles d’un binaire ELF64 little-endian (tri ASCII + adresse, format proche de `nm`).
- `ft_otool` reproduit `otool -t` en affichant le contenu hexadécimal de la section exécutable (`__text`).
- Parsing maison : mappage mémoire en lecture seule, validation d’entête ELF, résolution des sections/symboles.
- Gestion des erreurs (fichiers inexistants, format non supporté, symboles absents) avec messages explicites.

## Étapes principales
- Chargement via `mmap` + contrôles de bornes (`file.c`).
- Analyse ELF (`elf_parser.c`) : récupération des tables de symboles et chaîne, typage des symboles (`resolve_symbol_type`).
- Implémentation des commandes (`ft_nm.c`, `ft_otool.c`, `main_*`) en réutilisant le cœur commun.

## Compilation
```sh
make
```
- Produit les binaires `ft_nm` et `ft_otool` (dossier `build/` pour les objets).

## Utilisation
- `./ft_nm <fichier>` : affiche les symboles. Sans argument, cible `a.out`.
- `./ft_otool <fichier>` : dump la section texte en hexadécimal. Sans argument, cible `a.out`.
- Plusieurs fichiers : `ft_nm` ajoute un en-tête vide entre fichiers, `ft_otool` chaîne les sorties avec une ligne vide.

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Compile un binaire de démonstration, exécute `ft_nm` et `ft_otool`, et vérifie que le symbole `main` est listé et que la section texte contient des octets.
- Récapitulatif des commandes disponible dans `tests_realisation/COMMANDES.md`.
