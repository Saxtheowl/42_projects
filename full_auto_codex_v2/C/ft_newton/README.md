# ft_newton

Statut : DONE — moteur physique (projectile + collisions sphère/plan/sphère) avec tests auto et exports complets.

Dernière mise à jour (2025-12-26 07:27:59) : finalisation. Cibles fixes ou aléatoires seedées, bornage/vent/traînée, projo configurable, exports JSON/MD/CSV/trace, stats complètes (contacts sol/sphère/mur, premier contact), tests auto verts.

## Build & tests
```bash
make
make test   # lance tests_realisation/run_tests.sh
```

## Fonctionnalités
- Vecteur 3D, corps rigide sphère avec masse, restitution, rayon.
- Intégration semi-implicite (gravity) et collisions sphère/plan + sphère/sphère (impulsion avec restitution) avec friction au sol paramétrable.
- Scène catapulte (vitesse/angle/config fichier) + deux cibles statiques, ou chargement d’une scène personnalisée avec `--scene`.
- Exports : CSV de trajectoire, JSON état final, trace JSON multi-corps (`--trace-json`), stdout lisible.
- Physique : friction sol paramétrable, traînée quadratique optionnelle (`--drag`), vent constant (`--wind`), bornage optionnel (`--bounds`), masse/restitution du projectile configurables, arrêt auto optionnel (`--auto-stop`), nombre/espacement ou placement aléatoire des cibles (`--random-targets` + `--seed`).
- Stats/exports : fichier JSON/Markdown avec max_height, max_range, énergie initiale/finale, contacts sol/sphère/mur, temps simulé, steps, temps/portée du premier contact (`--stats-json`/`--stats-md`), énergie totale par pas en CSV (`--energy-csv`), trace JSON multi-corps (`--trace-json`).

## Exemple
```bash
./ft_newton --speed 10 --angle 45 --sim 3 --friction 0.4 --csv trace.csv --final-json final.json | head -n 5
# ou via config (INI simple)
cat > config.cfg <<'EOF'
speed=8
angle=20
dt=0.01
sim_time=2
friction=0.6
EOF
./ft_newton --config config.cfg --csv trace.csv

# Charger une scène personnalisée
# Charger une scène personnalisée
cat > scene.txt <<'EOF'
gravity=0,-9.81,0
ground_friction=0.3
drag=0.15
# body=m,radius,restitution,px,py,pz,vx,vy,vz
body=1.0,0.5,0.8,0,1,0,6,6,0
body=3.0,0.6,0.6,8,0.6,0,0,0,0
EOF
./ft_newton --scene scene.txt --dt 0.01 --sim 3 --final-json final.json --trace-json trace.json
```

## Backlog court terme
- Ajouter friction tangente sur collision et contacts multiples (sphère-sphère).
- Implémenter un solver itératif pour empilements simples (box/sphere/plane).
- Extendre le loader de scène (formats denses, matériaux multiples, contrôles d’erreurs détaillés).
