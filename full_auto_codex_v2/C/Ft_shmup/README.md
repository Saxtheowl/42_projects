# ft_shmup

Dernière mise à jour (2025-12-26 04:10:00) : campagne finie (15 vagues puis victoire bonus), power-ups multiples, boss récurrents, HUD détaillé (boss, timers, top scores persistants), adaptation à la taille du terminal (min 20x12).

## Build
```bash
make
```

## Lancer le jeu
```bash
./ft_shmup
```

### Contrôles
- `flèches` ou `WASD` : déplacer le vaisseau.
- `espace` : tirer.
- `p` : pause.
- `q` : quitter.

### Gameplay actuel
- Défilement vertical du fond (étoiles).
- Vagues d’ennemis qui descendent (pattern horizontal léger) et tirent périodiquement; wave affichée (campagne 15 vagues). Boss toutes les 5 vagues (HP multiples, triple tir).
- Collisions : si un ennemi ou tir touche le joueur → perte d’une vie (3 vies au départ).
- Les tirs du joueur détruisent un ennemi (score +10).
- Power-ups (`+`) tombent parfois (garantis sur boss) : vie (+1, max 5, +50 pts), bouclier (invulnérable ~5s), tir rapide (~6s).
- Courte invulnérabilité après chaque hit (respawn centré).
- Affichage HUD (score, high score, top scores, vies, wave/total, boss HP, timers de power-ups) sous la zone de jeu; high scores persistants via `highscore.txt`. Le jeu ajuste sa zone d’affichage à la taille du terminal (min 20x12 utilisables).

### À faire / pistes bonus
- Son, niveaux scriptés, boss, multi, power-ups.
- Améliorer l’IA ennemie et la difficulté progressive.
- Sauvegarde des meilleurs scores.
