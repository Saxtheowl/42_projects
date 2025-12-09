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
- [x] Renderer fallback PPM : `RT` génère `output.ppm` (par défaut 800x600) avec ray tracing de base (diffuse/specular, ombres, sphère/plan/cylindre/cône), sky gradient, supersampling configurable, rendu multi-thread, gamma correction, réflexions (1 rebond) via un coefficient optionnel.
- [ ] Intégration renderer MLX (affichage temps réel) en complément du PPM (lib mlx absente sur l'env).

Mise à jour (2025-12-08 23:00:33) : PPM amélioré (fond ciel, supersampling, multithread), CLI enrichie (`--out`, `--size`, `--samples`, `--threads`); MLX toujours en attente.
Mise à jour (2025-12-09 00:03:30) : Ajout d’une atténuation quadratique des lumières pour éviter la surexposition sur les plans proches et rendre le shading plus réaliste (diffuse/specular pondérés par la distance).
Mise à jour (2025-12-09 00:09:06) : Ajout des spots directionnels (position + direction + cutoff) dans le parser/rendu; nouvelle scène `assets/scenes/spotlight.rt` pour tester le faisceau et le fill light.
Mise à jour (2025-12-09 00:12:44) : Ajout du brouillard exponentiel global (`fog densité r g b`) mixé selon la distance caméra→objet; scène `assets/scenes/foggy.rt` pour illustrer.
Mise à jour (2025-12-09 00:18:26) : Matériaux transparents/réfractifs (coeff `transparency` et IOR optionnels) avec refraction simple; scène `assets/scenes/glass.rt` pour tester le verre.
Mise à jour (2025-12-09 00:23:54) : Profondeur de champ (aperture/focal_dist optionnels sur `camera`) avec jitter sur le disque de lentille; scène `assets/scenes/dof.rt` pour démontrer le bokeh.
Mise à jour (2025-12-09 00:29:20) : Ombres douces via un rayon optionnel sur les lights (multi shadow rays); scène `assets/scenes/soft_shadow.rt` dédiée.
Mise à jour (2025-12-09 00:33:24) : Primitive triangle (parser + intersection) et scène `assets/scenes/triangles.rt` (plaque triangulaire + triangle dressé).
Mise à jour (2025-12-09 00:37:48) : Loader OBJ minimal (`mesh path ...`) qui triangule les faces et génère des triangles; exemple `assets/scenes/mesh.rt` + `assets/meshes/quad.obj`.
Mise à jour (2025-12-09 00:43:13) : `mesh` supporte un scale/translate optionnel (sx sy sz tx ty tz) appliqué aux sommets; nouvelle scène `assets/scenes/mesh_scaled.rt` pour illustrer.
Mise à jour (2025-12-09 00:48:23) : Ajout du roughness pour les reflets (réflexions glossy jitterisées); scène `assets/scenes/glossy.rt` pour tester les reflets flous.
Mise à jour (2025-12-09 00:54:17) : Loader OBJ étendu : normals `vn` + faces `v//n` supportées, normales interpolées sur les triangles; scènes `assets/scenes/mesh_normals.rt` et `assets/meshes/pyramid.obj`.
Mise à jour (2025-12-09 00:58:21) : Matériaux émissifs (`emission_strength r g b`) pour auto-éclairage des surfaces; scène `assets/scenes/emissive.rt` avec panneau lumineux.
Mise à jour (2025-12-09 01:02:45) : Mélange réflexion/réfraction plus physique via Fresnel (Schlick) pour pondérer dynamiquement refl/trans.
Mise à jour (2025-12-09 01:12:56) : Textures PPM optionnelles (sphère/plan/mesh/triangle) + scène `assets/scenes/textured.rt` et texture `assets/textures/checker.ppm`.
Mise à jour (2025-12-09 01:17:37) : Support UV OBJ (`vt` + faces v/vt/vn) et échantillonnage barycentrique sur triangles texturés.
Mise à jour (2025-12-09 01:23:34) : Ajout uv_scale (tile textures) sur sphères/plans/triangles/meshes; scène `assets/scenes/textured_tiled.rt` démontre le tiling.

## Format de scène (proposition)
Chaque ligne : `token arguments`. Les valeurs sont des floats (ou int) séparés par des espaces.
- `camera px py pz dx dy dz fov [aperture] [focal_dist]` — position/direction caméra, FOV en degrés; aperture > 0 active la profondeur de champ, focal_dist fixe le plan net.
- `light px py pz i r g b [radius]` — point light (intensité 0-1, couleur 0-255), rayon optionnel pour ombres douces.
- `spot px py pz dx dy dz cutoff_deg i r g b [radius]` — spot orienté; direction normalisée, cutoff en degrés, rayon optionnel pour ombres douces.
- `fog density r g b` — brouillard exponentiel global, densité >= 0.
- `ambient i r g b` — lumière ambiante.
- `sphere px py pz radius r g b kd ks shininess [reflect transparency ior roughness emission_strength er eg eb [texture.ppm]]`
- `plane px py pz nx ny nz r g b kd ks shininess [reflect]`
- `cylinder px py pz dx dy dz radius height r g b kd ks shininess [reflect]`
- `cone px py pz dx dy dz angle_deg height r g b kd ks shininess [reflect]`
- `box px py pz sx sy sz r g b kd ks shininess [reflect]`
- `triangle x1 y1 z1 x2 y2 z2 x3 y3 z3 r g b kd ks shininess [reflect transparency ior]`
- `mesh path r g b kd ks shininess [reflect transparency ior roughness emission_strength er eg eb [texture.ppm] [sx sy sz tx ty tz]]` — charge un OBJ (v/f/vn), faces triangulées, normales optionnelles, transformées (scale/translate), avec les mêmes options de matériau.
Où `kd/ks` sont coefficients diffuse/specular. Les directions (dx dy dz) doivent être normalisées dans la scène ou lors du parse.
L'option `reflect` est facultative (0-1) pour mélanger une réflexion (un rebond).

CLI actuelle : `./RT [scene.rt] [--out output.ppm] [--size WxH] [--samples N] [--threads N] [--gamma G] [--maxdepth D] [--depth depth.ppm] [--normal normals.ppm] [--tonemap none|reinhard|aces] [--sky r1 g1 b1 r0 g0 b0]`. Génère un PPM (fallback) jusqu'à disponibilité de la MLX; `--depth` exporte une carte de profondeur, `--normal` une carte de normales; `--sky` permet de définir le dégradé (haut/bas). Les plans peuvent recevoir un motif checker optionnel (`... kd ks shininess reflect checker_size r g b`).

Scènes fournies :
- `assets/scenes/sample.rt` : scène de démonstration simple (sphère + plan + cylindre + cône).
- `assets/scenes/room.rt` : petite pièce avec murs colorés, deux lumières, sphère/cylindre/cône pour tester les ombres multiples.
- `assets/scenes/box.rt` : boîte réfléchissante, checker au sol, sphère et cône pour tester le nouveau primitive.
- `assets/scenes/spotlight.rt` : éclairage principal en spot orienté + point fill pour tester les cutoff et la direction.
- `assets/scenes/foggy.rt` : brouillard exponentiel global avec spot + point light pour visualiser l’atténuation atmosphérique.
- `assets/scenes/glass.rt` : sphère en verre (transparency + IOR) avec spot/point et plan checker pour tester la réfraction.
- `assets/scenes/dof.rt` : profondeur de champ (aperture/focal_dist) avec sphere/box/cone pour visualiser le bokeh.
- `assets/scenes/soft_shadow.rt` : zone lights avec rayon pour produire des ombres douces.
- `assets/scenes/triangles.rt` : triangles (plaque + triangle dressé) pour vérifier l’intersection triangle.
- `assets/scenes/mesh.rt` : quad OBJ chargé via `mesh`, plus triangle supplémentaire.
- `assets/scenes/mesh_scaled.rt` : démonstration du scale/translate appliqué au mesh (quad agrandi et décalé + quad réduit).
- `assets/scenes/glossy.rt` : reflets flous via roughness sur sphere/box/cone.
- `assets/scenes/mesh_normals.rt` : mesh OBJ avec normals (`pyramid.obj`) pour vérifier l’interpolation.
- `assets/scenes/emissive.rt` : panneau lumineux émissif + objets diffus/réfléchissants.
- `assets/scenes/textured.rt` : plan + sphère texturés (checker PPM).
- `assets/scenes/textured_tiled.rt` : démonstration du tiling via uv_scale sur plan/sphère.
