# Graphical Project

## Synthèse
Sujet RT (ray tracing) : rendu d’images 3D en ray tracing avec au moins quatre objets simples (plan, sphère, cylindre, cône), transformations (translation/rotation), gestion des vues/redraw, lumières (multi-spot, ombres, shininess). Exe obligatoire : `RT`. Langage au choix (C/C++/Rust) avec lib graphique bas niveau (mlx, OpenGL/Vulkan/Metal…). Bonus variés : lumière ambiante/directe/dirigée, objets limités/composés, textures/bump, transparence/réflexion, parsing fichiers scènes, etc.

## Avancement
- [x] Copie du sujet (`docs/Graphical_Project.pdf`).
- [x] Lecture rapide : contraintes générales et exigences mandat identifiées (objets, lumières, redraw, exe `RT`).
- [x] Arborescence de base créée (`src/`, `include/`, `assets/scenes/`, `docs/`).
- [x] Planification préliminaire : C + MiniLibX (fallback OpenGL/PPM si mlx absente), fichier scène texte.
- [x] Format scène texte défini (caméra, lumières, plan/sphère/cylindre/cône, matériaux).
- [x] Implémentation parser + binaire `RT` qui charge et affiche la scène (sample.rt).
- [x] Renderer fallback PPM : `RT` génère `output.ppm` (par défaut 800x600) avec ray tracing de base (diffuse/specular, ombres, sphère/plan/cylindre/cône) + sky gradient + supersampling configurable + rendu multi-thread.
- [ ] Intégration renderer MLX (affichage temps réel) en complément du PPM (lib mlx absente sur l'env).

Mise à jour (2025-12-08 23:00:33) : PPM amélioré (fond ciel, supersampling, multithread), CLI enrichie (`--out`, `--size`, `--samples`, `--threads`); MLX toujours en attente.

## Format de scène (proposition)
Chaque ligne : `token arguments`. Les valeurs sont des floats (ou int) séparés par des espaces.
- `camera px py pz dx dy dz fov` — position et direction caméra normalisée, FOV en degrés.
- `light px py pz i r g b` — point light avec intensité i (0-1) et couleur (0-255).
- `ambient i r g b` — lumière ambiante.
- `sphere px py pz radius r g b kd ks shininess`
- `plane px py pz nx ny nz r g b kd ks shininess`
- `cylinder px py pz dx dy dz radius height r g b kd ks shininess`
- `cone px py pz dx dy dz angle_deg height r g b kd ks shininess`
Où `kd/ks` sont coefficients diffuse/specular. Les directions (dx dy dz) doivent être normalisées dans la scène ou lors du parse.

CLI actuelle : `./RT [scene.rt] [--out output.ppm] [--size WxH] [--samples N] [--threads N]`. Génère un PPM (fallback) jusqu'à disponibilité de la MLX.

Scènes fournies :
- `assets/scenes/sample.rt` : scène de démonstration simple (sphère + plan + cylindre + cône).
- `assets/scenes/room.rt` : petite pièce avec murs colorés, deux lumières, sphère/cylindre/cône pour tester les ombres multiples.
