# AlCu - Rush sur les algorithmes

## Synthese
Jeu de Nim variant (AlCu) : N tas, chaque coup retire 1 a 3 objets du dernier tas. Deux joueurs, l'IA commence, le joueur qui prend le dernier objet perd. Entree via fichier/stdin (lignes = tailles de tas, 1..10000, ligne vide de fin). Affichage du plateau entre chaque tour, IA doit essayer de gagner.

## Avancement
- [x] Sujet copie (`docs/AlCu.pdf`).
- [x] Lecture rapide, exigences comprises (format d'entree, IA, affichage).
- [x] Parser + boucle de jeu : lecture stdin/fichier (lignes 1..10000), affichage plateau, validation coups.
- [x] IA strategique (memoisation pour positions gagnantes sur piles sequencielles), IA commence.
- [x] Polissage saisie utilisateur (nettoyage ligne en cas d'erreur, EOF -> abandon propre).

Mise a jour (2025-12-06 20:05:37) : Jeu AlCu terminé et jouable en CLI (IA mémoisée + saisie robuste).

## Usage
```bash
./alcu < map.txt
# ou
./alcu map.txt
```
Format d'entree : chaque ligne = taille d'un tas (1..10000), ligne vide pour terminer si stdin; IA joue en premier.
