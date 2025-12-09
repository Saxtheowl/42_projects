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
- [x] Intégration renderer MLX (MiniLibX) en complément du PPM avec `--mlx`/overlays/snapshots même si la lib n'est pas fournie par défaut.

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
Mise à jour (2025-12-09 01:27:40) : Textures échantillonnées en bilinéaire pour éviter l’aliasing (wrap); applicable à tous les objets texturés.
Mise à jour (2025-12-09 01:32:53) : Ajustements CLI (doc options matériaux/texture) et wrap bilinéaire consolidé.
Mise à jour (2025-12-09 01:38:46) : Ajout des lumières directionnelles (`dirlight`/`sun`) avec intensité/couleur/rayon soft; scène `assets/scenes/sun.rt`.
Mise à jour (2025-12-09 01:42:51) : Mesh: rotation optionnelle (rx ry rz) après scale/translate + scène `assets/scenes/mesh_rotated.rt`; env map et lights support inchangés.
Mise à jour (2025-12-09 01:53:52) : Ajout envmap `env ...` pour le fond (échantillonnage sphérique) + PPM binaire optionnel `--binary` (P6) pour accélérer l’export; `assets/scenes/envmap.rt` illustre l’option.
Mise à jour (2025-12-09 02:04:21) : Normal maps PPM (tangent space) sur sphères/plans/meshes UV, syntaxe `[texture.ppm [uv_scale_u uv_scale_v [normal.ppm]]]`, scène `assets/scenes/normal_mapped.rt` + normal map `assets/textures/tilt_normal.ppm`; MLX toujours manquante.
Mise à jour (2025-12-09 02:06:18) : Camera accepte un vecteur up optionnel (roll) `camera ... [aperture] [focal_dist] [upx upy upz]`; scène `assets/scenes/tilted_camera.rt` démontre le cadrage incliné; MLX toujours manquante.
Mise à jour (2025-12-09 02:08:16) : Textures/envmaps P3 ou P6 (binaire) supportées; nouvelle texture `assets/textures/env_p6.ppm` et scène `assets/scenes/envmap_p6.rt` pour valider le chargement P6.
Mise à jour (2025-12-09 02:16:01) : Accélération BVH (AABB) pour les objets finis (sphères/boxes/meshes/cylindres/cônes/triangles) avec parcours rapide; plans restent évalués linéairement; aucune syntaxe ajoutée. MLX toujours manquante.
Mise à jour (2025-12-09 02:18:34) : Loader OBJ gère les faces n-gones (triangulation en éventail) + nouvelle mesh `assets/meshes/polygon.obj` et scène `assets/scenes/mesh_polygon.rt`; MLX toujours manquante.
Mise à jour (2025-12-09 02:23:39) : Option `--no-bvh` pour désactiver l’accélération BVH (debug) avec fallback linéaire conservé.
Mise à jour (2025-12-09 02:28:34) : Ambiant Occlusion optionnelle (`--ao radius samples`) appliquée sur la composante ambiante pour ajouter de la profondeur locale.
Mise à jour (2025-12-09 02:34:12) : Support sRGB -> linéaire pour les textures (`--srgb-textures`) afin d’éclairer dans l’espace linéaire; MLX toujours manquante.
Mise à jour (2025-12-09 02:38:34) : Option `--exposure` pour multiplier l’image avant tonemap/gamma (contrôle de l’intensité générale).
Mise à jour (2025-12-09 02:43:34) : Echantillonnage glossy configurable (`--glossy-samples`) pour réduire le bruit des reflets flous; MLX toujours manquante.
Mise à jour (2025-12-09 02:50:15) : Export ID map par objet (`--id id.ppm`) pour debug/compositing (couleurs hashées par index objet).
Mise à jour (2025-12-09 02:54:20) : Eclairage environnemental diffus : `--env-samples` échantillonne l’envmap sur l’hémisphère de la normale pour ajouter de la lumière indirecte.
Mise à jour (2025-12-09 03:00:55) : Export cartes albedo (`--albedo`) et position (`--position`, clamp [-10,10]) en plus de depth/normal/ID; lighting indirect envmap conservé; MLX toujours manquante.
Mise à jour (2025-12-09 03:10:08) : Ajout d’un seed global `--seed` (reproductible) et export albedo/position en PPM pour le debug, plus échantillonnage env map avec seed mixé.
Mise à jour (2025-12-09 03:19:24) : Option `--pos-range` pour contrôler le clamp des cartes position (par défaut ±10) et synchronisation du seed global sur tous les tirages.
Mise à jour (2025-12-09 03:27:36) : Option `--clamp` pour borner la luminance linéaire avant tonemap (0 = off) et parsing CLI clarifié (flags id/albedo/position/seed/clamp regroupés).
Mise à jour (2025-12-09 03:31:13) : Ajout `--bin-buffers` pour exporter depth/normal/id/albedo/position en P6 binaire (plus rapide) en plus du P3 texte.
Mise à jour (2025-12-09 03:38:12) : Option `--stats` pour consigner width/height/samples/threads/gamma/maxdepth/exposure/binary/binary_buffers/duration dans un fichier après le rendu.
Mise à jour (2025-12-09 03:43:07) : `--stats` écrit désormais le nombre exact de threads employés (déduit de la hauteur + du mode auto) pour aligner les données avec le rendu.
Mise à jour (2025-12-09 03:48:16) : `--stats-append` permet de cumuler les fiches sans écraser celles déjà générées (`--stats` continue d’indiquer les threads auto-détectés + durée).
Mise à jour (2025-12-09 03:53:00) : `--stats` consigne désormais glossy/env/pos_range/clamp/ao/env_intensity en plus des valeurs de base, ce qui facilite la comparaison entre rendus; `--stats-append` conserve les fichiers multi-rendus.  
Ajout option `--env-intensity` pour multiplier l’éclairage diffus issu de l’envmap (1.0 par défaut).
Mise à jour (2025-12-09 03:59:19) : `--env-intensity` s’applique à l’éclairage diffus provenant de l’envmap, ce qui permet de renforcer ou atténuer l’ambiance globale sans toucher à la texture; surbrillance du doc CLI et stats.
Mise à jour (2025-12-09 04:23:20) : `--stats-camera` ajoute la position/direction caméra dans la fiche stats pour relier une configuration aux images générées.
Mise à jour (2025-12-09 04:32:54) : `--stats-json` écrit les mêmes métriques que `--stats` en JSON (append si `--stats-append`, `--stats-camera` reste compatible); MLX toujours manquante.
Mise à jour (2025-12-09 04:34:30) : `--stats-json -` pipe la même sortie JSON vers stdout pour les pipelines (compatible `--stats-camera`); MLX toujours manquante.
Mise à jour (2025-12-09 04:34:30) : `--stats-json -` imprime la même sortie JSON sur stdout pour les pipelines, avec `--stats-camera` toujours compatible; MLX toujours manquante.
Mise à jour (2025-12-09 04:54:33) : `--stats-csv` duplique les métriques de `--stats` au format CSV (colonnes timestamp, scene, width, height, ..., duration) et `--stats-csv-append` conserve les lignes précédentes pendant que `--stats-camera` ajoute les colonnes `cam_pos_*`/`cam_dir_*`; MLX toujours manquante.
Mise à jour (2025-12-09 04:57:58) : `--stats-csv -` envoie la même sortie CSV sur stdout pour les pipelines automatiques (les colonnes restent identiques, `--stats-camera` ajoute les colonnes caméra); MLX toujours manquante.
Mise à jour (2025-12-09 05:03:14) : `--stats`, `--stats-json` et `--stats-csv` enregistrent maintenant la graine `--seed` utilisée pour tous les tirages et l’incluent dans les sorties (texte/JSON/CSV), ce qui rend les rendus et stats entièrement reproductibles; MLX toujours manquante.
Mise à jour (2025-12-09 05:10:00) : Ajout de `--stats-console` qui imprime un résumé des métriques (scene,width,...,duration) sur `stderr` ainsi que l’option `--stats-camera` pour ajouter la ligne caméra, ce qui permet de superviser les rendus dans CI sans toucher les fichiers; MLX toujours manquante.
Mise à jour (2025-12-09 05:15:25) : `--stats-comment` injecte un texte libre dans les exports (`stats`, `stats-json`, `stats-csv`, `stats-console`) pour annoter facilement les rendus lors de la collecte de données; MLX toujours manquante.
Mise à jour (2025-12-09 05:20:10) : `--stats-console-json` émet les mêmes métriques que `--stats-console` mais en JSON sur `stderr` (commentaires et caméra inclus), ce qui facilite l’analyse automatisée tout en gardant `--stats-console` en mode texte; MLX toujours manquante.
Mise à jour (2025-12-09 05:30:00) : `--stats-console-stdout` redirige les sorties `--stats-console`/`--stats-console-json` vers `stdout` plutôt que `stderr`, ce qui aide les workflows qui lisent `stdout`; `--stats-camera` reste compatible; MLX toujours manquante.
Mise à jour (2025-12-09 05:35:00) : `--stats-ms` ajoute `duration_ms` et `duration_unit` aux exports (texte, JSON, CSV, console) pour mesurer les rendus en millisecondes tout en conservant la durée en secondes; MLX toujours manquante.
Mise à jour (2025-12-09 05:38:16) : `--stats-comment-env VAR` remplace le commentaire `stats` par la valeur de la variable d’environnement `VAR` lorsqu’il n’est pas fourni, ce qui permet de propager dynamiquement les annotations depuis le contexte d’exécution; MLX toujours manquante.
Mise à jour (2025-12-09 05:34:35) : `--stats-env VAR` capture la valeur d’une variable d’environnement (max 8) et l’ajoute aux sorties `stats`/`stats-json`/`stats-csv`/`stats-console` (`env_vars`), ce qui documente l’environnement de rendu; MLX toujours manquante.
Mise à jour (2025-12-09 05:40:00) : `--stats-tag key=value` insère des tags personnalisés (`tags=key=value;...`) dans les exports texte/JSON/CSV/console, facilitant l’identification des rendus poussés par des scripts; MLX toujours manquante.
Mise à jour (2025-12-09 05:45:00) : `--stats-group name` ajoute `group=name` dans tous les exports (texte, JSON, CSV, console) pour catégoriser rapidement les rendus générés par des suites distinctes; MLX toujours manquante.
Mise à jour (2025-12-09 06:50:00) : `--mlx` affiche la `render_frame`, `D` écrit `--mlx-depth <path>` pour capturer la carte de profondeur, `--mlx-overlay` ajoute un texte flottant, et `--mlx-auto-snapshot`/`--mlx-auto-depth` restituent les PPM immédiatement après le rendu sans lancer MLX; MLX toujours en attente.
Mise à jour (2025-12-09 06:15:00) : Option `--mlx` qui appelle `display_frame_with_mlx(frame)` (via le module `mlx_bridge.c`) pour ouvrir une fenêtre MiniLibX et blitter le buffer déjà calculé par `render_frame`; la compilation échoue si `USE_MLX` n’est pas défini, l’option reste silencieuse sinon; MLX toujours en attente.
Mise à jour (2025-12-09 06:05:00) : Ajout de l’API `render_frame`/`free_render_frame` qui capture le buffer couleurs/profondeur/normales/IDs issu de la pipeline PPM, ce qui prépare un module MLX/fenêtre temps réel à réutiliser le rendu sans répliquer la logique; MLX toujours en attente.
Mise à jour (2025-12-09 05:50:00) : `--stats-fps` calcule les FPS (samples/duration) et l’ajoute aux sorties (`fps`), apportant une métrique de cadence à tous les exports; MLX toujours manquante.

## Format de scène (proposition)
Chaque ligne : `token arguments`. Les valeurs sont des floats (ou int) séparés par des espaces.
- `camera px py pz dx dy dz fov [aperture] [focal_dist] [upx upy upz]` — position/direction caméra, FOV en degrés; aperture > 0 active la profondeur de champ, focal_dist fixe le plan net; up optionnel permet un roll personnalisé.
- `light px py pz i r g b [radius]` — point light (intensité 0-1, couleur 0-255), rayon optionnel pour ombres douces.
- `spot px py pz dx dy dz cutoff_deg i r g b [radius]` — spot orienté; direction normalisée, cutoff en degrés, rayon optionnel pour ombres douces.
- `fog density r g b` — brouillard exponentiel global, densité >= 0.
- `env path.ppm` — env map PPM (P3 ou P6) sphérique pour le fond.
- `ambient i r g b` — lumière ambiante.
- `sphere px py pz radius r g b kd ks shininess [reflect transparency ior roughness emission_strength er eg eb [texture.ppm [uv_scale_u uv_scale_v [normal.ppm]]]]`
- `plane px py pz nx ny nz r g b kd ks shininess [reflect transparency ior roughness emission_strength er eg eb [texture.ppm [uv_scale_u uv_scale_v [normal.ppm]]]]`
- `cylinder px py pz dx dy dz radius height r g b kd ks shininess [reflect]`
- `cone px py pz dx dy dz angle_deg height r g b kd ks shininess [reflect]`
- `box px py pz sx sy sz r g b kd ks shininess [reflect]`
- `triangle x1 y1 z1 x2 y2 z2 x3 y3 z3 r g b kd ks shininess [reflect transparency ior roughness emission_strength er eg eb [texture.ppm [uv_scale_u uv_scale_v [normal.ppm]]]]`
- `mesh path r g b kd ks shininess [reflect transparency ior roughness emission_strength er eg eb [texture.ppm [uv_scale_u uv_scale_v [normal.ppm]]] [sx sy sz tx ty tz rx ry rz]]` — charge un OBJ (v/f/vn/vt), faces triangulées (n-gones supportés en fan), normales/UV optionnelles, transformées (scale/translate/rotation XYZ), avec les mêmes options de matériau.
Où `kd/ks` sont coefficients diffuse/specular. Les directions (dx dy dz) doivent être normalisées dans la scène ou lors du parse.
L'option `reflect` est facultative (0-1) pour mélanger une réflexion (un rebond).

## Aperçu MLX

Compilez avec `make USE_MLX=1` (ajustez `MLX_LIBS` si vos headers/objets se trouvent dans des répertoires non standards) pour activer `--mlx`. Cette option appelle `display_frame_with_mlx`, réutilise le buffer `render_frame` et affiche une fenêtre MiniLibX avec une capture statique. Les touches `S`/`s` déclenchent `write_frame_snapshot` (`--mlx-snapshot` définit le chemin, défaut `mlx_snapshot.ppm`), `D`/`d` sauvegardent la carte de profondeur (`--mlx-depth`, défaut `mlx_depth.ppm`), et `Esc`/`close` ferment la fenêtre. `--mlx-overlay "texte"` dessine un label flottant. `--mlx-auto-snapshot path` et `--mlx-auto-depth path` restent compatibles même sans afficheur : elles exportent directement les PPM après le rendu et retournent un code d’état ami.

## Statistiques et journalisation

`--stats FILE` écrit une fiche (width/height/samples/threads/gamma/max_depth/exposure/binary/binary_buffers/glossy_samples/env_samples/pos_range/clamp/ao_samples/env_intensity/lights/seed/avg_luminance/max_luminance/min_luminance/std_luminance/duration/duration_unit/scene/timestamp) et (`--stats-append`) conserve les rendus successifs. `--stats-camera` ajoute la position/direction de la caméra, `--stats-comment "texte"` injecte un commentaire libre (ou `--stats-comment-env VAR` qui lit `VAR` avant d’écrire), `--stats-env VAR` capture jusqu’à 8 variables d’environnement, `--stats-tag clé=valeur` rassemble des tags `tags=...`, `--stats-group nom` classe un groupe, `--stats-ms`/ou `--stats-fps` ajoutent respectivement les durées en millisecondes et la cadence `samples/duration`. `--stats-json [PATH|-]` et `--stats-csv [PATH|-]` produisent des sorties JSON/CSV (avec `--stats-json -` ou `--stats-csv -` pour la sortie stdout, `--stats-csv-append` préserve les en-têtes), et `--stats-console`, `--stats-console-json`, `--stats-console-stdout` dupliquent ces données sur stderr/JSON/plain. Toutes ces options sont compatibles avec `--stats-camera`, `--stats-append` et `--stats-json`/`--stats-csv` afin de tracer précisément chaque rendu.

## Interface de ligne de commande

`./RT scene.rt` génère un rendu PPM (P3 ou P6 avec `--binary`). Les options principales incluent :

- **Sorties et résolution** : `--out sortie.ppm`, `--size WxH`, `--samples N`, `--threads N`, `--gamma G`, `--maxdepth D`.
- **Caches et exports** : `--depth depth.ppm`, `--normal normal.ppm`, `--id id.ppm`, `--albedo albedo.ppm`, `--position pos.ppm`, `--bin-buffers` pour écrire les buffers en P6, `--binary` pour l’image finale.
- **Matériaux, environnement et tonemapping** : `--tonemap none|reinhard|aces`, `--sky r1 g1 b1 r0 g0 b0`, `--env-intensity X`, `--srgb-textures`, `--exposure X`, `--glossy-samples N`, `--env-samples N`, `--pos-range R`, `--clamp C`, `--ao radius samples`.
- **Prévisibilité et scènes** : `--seed S` fixe la graine des tirages, `--no-bvh` force le parcours linéaire (utile pour déboguer la BVH).
- **Statistiques** : les outils `--stats`, `--stats-append`, `--stats-camera`, `--stats-json`, `--stats-json -`, `--stats-csv`, `--stats-csv -`, `--stats-csv-append`, `--stats-console`, `--stats-console-json`, `--stats-console-stdout`, `--stats-comment`, `--stats-comment-env`, `--stats-env`, `--stats-tag`, `--stats-group`, `--stats-ms`, `--stats-fps` permettent d’exporter des métriques détaillées et des annotations pour pipelines automatisés.
- **Fenêtre MiniLibX** : `--mlx` affiche `display_frame_with_mlx`, `--mlx-snapshot chemin`, `--mlx-depth chemin`, `--mlx-overlay "texte"`, `--mlx-auto-snapshot chemin`, `--mlx-auto-depth chemin` capturent le frame calculé sans relancer le rendu.

À noter : `--depth`/`--normal`/`--id`/`--albedo`/`--position` extraient les données auxiliaires (P3 ou P6), `--pos-range` clamp les cartes position, `--stats` agrège toutes les métriques, et `--stats-json -` ou `--stats-csv -` permettent d’enchaîner l’analyse dans des scripts sans écrire de fichier.

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
- `assets/scenes/mesh_rotated.rt` : exemple de rotation mesh (quad pivoté et décalé).
- `assets/scenes/sun.rt` : lumière directionnelle + fill light.
- `assets/scenes/envmap.rt` : fond envmap PPM + simple éclairage.
- `assets/scenes/normal_mapped.rt` : plan checker tuilé avec normal map PPM pour simuler du relief + lumière douce.
- `assets/scenes/tilted_camera.rt` : exemple de caméra avec roll (vecteur up personnalisé) + normal map sur le sol.
- `assets/scenes/envmap_p6.rt` : env map binaire P6 (2x2) pour valider le support P3/P6.
- `assets/scenes/mesh_polygon.rt` : mesh OBJ contenant un pentagone (n-gone) triangulé automatiquement.
