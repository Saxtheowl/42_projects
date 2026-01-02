# ft_shmup

Dernière mise à jour (2026-01-02 18:58:57) : projet stabilisé, statut DONE.
Statut : DONE

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
- `h` : afficher/masquer l’aide.
- `q` : quitter (confirmation y/n).
- `x` : sortir directement en fin de partie.
- `r` : relancer une partie après Game Over / Victory.
- `b` : déclencher une bombe (si disponible).
- `e` : dash (déplacement rapide avec courte invulnérabilité).
- `f` : activer/désactiver le tir automatique.
- `t` : retour à l’écran titre (après une partie).
- `m` : changer le mode (endless/campaign) à l’écran titre.

### Écran titre
Un écran titre affiche le rappel des commandes. Démarrage avec `espace` ou `entrée`. `m` bascule entre la campagne (15 vagues) et le mode endless.

### Gameplay actuel
- Défilement vertical du fond (étoiles).
- Vagues d’ennemis qui descendent (pattern horizontal léger) et tirent périodiquement + kamikazes qui suivent la position du joueur + snipers qui tirent des projectiles dirigés; bannière de vague (Wave X) et boss (Boss wave!) au début de chaque cycle. Boss toutes les 5 vagues (HP multiples, triple tir) avec phase enraged (cadence accrue, kamikazes en renfort).
- Collisions : si un ennemi ou tir touche le joueur → perte d’une vie (3 vies au départ).
- Les tirs du joueur détruisent un ennemi (score +10).
- Power-ups (`+`, `U`, `R`, `S`, `Z`, `B`) tombent parfois (garantis sur boss) : vie (+1, max 5, +50 pts), bouclier (invulnérable ~5s), tir rapide (~6s), tir en éventail (~7s), slow time (~5s), bombe (nettoyage tirs/ennemis).
- Courte invulnérabilité après chaque hit (respawn centré). Combo de kills si plusieurs ennemis sont détruits à moins de 2s d’intervalle (bonus score).
- Affichage HUD (score, high score, top scores, vies, wave/total, boss HP, timers de power-ups) sous la zone de jeu; high scores persistants via `highscore.txt`. Le jeu ajuste sa zone d’affichage à la taille du terminal (min 20x12 utilisables).

### À faire / pistes bonus
- Son, niveaux scriptés, boss, multi, power-ups.
- Améliorer l’IA ennemie et la difficulté progressive.
- Sauvegarde des meilleurs scores.
