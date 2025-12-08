# Plan Graphical Project

## Étapes
- [x] Lecture rapide du sujet (`docs/Graphical_Project.pdf`) et identification des livrables.
- [ ] Lecture détaillée + prise de notes (objets, transformations, lumières, redraw).
- [x] Choix technos préliminaire : C + MiniLibX (si dispo) ; fallback OpenGL/SDL2 ou génération PPM offline si mlx absente. Vérifier dépendances.
- [x] Définir arborescence cible (`src`, `include`, `assets/scenes`, build/Makefile, tests).
- [x] Spécifier format scène minimal (fichier texte) : caméra, lumières, objets plan/sphère/cylindre/cône avec matériaux (kd/ks/shininess).
- [x] Implémentation initiale : parsing scène et binaire `RT` qui charge `sample.rt` et affiche le contenu.
- [x] Renderer fallback PPM (800x600) : ray tracing diffuse/specular, ombres, sphère/plan/cylindre/cône; sortie `output.ppm`.
- [ ] Intégration renderer MLX temps réel (ou SDL/OpenGL si mlx absente).
- [ ] Tests (scènes de référence, vues multiples), perf baseline.
- [ ] Bonus éventuels (ambiant/directionnel, objets limités, reflets/transparence, textures, composés).
- [ ] Documentation finale (README, usage, scènes exemples).

Journal (2025-12-06 09:35:35) : PPM fallback en place (output.ppm), parser complet; blocage MLX (bibliothèque absente) à lever avant affichage temps réel.
