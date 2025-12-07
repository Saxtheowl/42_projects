# Expert system

## Synthese
Implémenter un moteur d'inférence (backward chaining) pour le calcul propositionnel. Entrée : fichier texte décrivant des règles (A + B => C, etc.), faits initiaux (=ABG), requêtes (?XYZ). L'engine doit répondre vrai/faux/indéterminé pour chaque requête (support AND, OR, XOR, NOT, parenthèses, règles multiples, AND en conclusion; bonus: OR/XOR en conclusion, biconditionnel, interaction). Erreurs d'entrée doivent être signalées.

## Avancement
- [x] Copie du sujet (`docs/Expert_system.pdf`).
- [x] Lecture rapide des exigences (backward-chaining, format fichier, opérateurs + | ^ ! => <=>, commentaires #).
- [x] Squelette projet posé (Makefile, src/main.c, modules AST + parser d'expressions).
- [x] Parser complet (règles/faits/requêtes) + moteur backward-chaining basique (propagation déterministe sur conclusions composées de symboles/!symbole/AND, <=> déplié en deux règles, détection simple des cycles, faits initiaux pris en charge, contradictions A/!A -> indéterminé, OR/XOR partiellement supportés via contraintes simples sur des littéraux connus).
- [ ] Tests exhaustifs + résolution complète des conclusions complexes (OR/XOR avec branches inconnues) et contradictions multiples.

## Usage
```sh
make
make test   # lance les tests dans tests/run_tests.sh
./expert <input_file>
```
Chaque ligne de règle est lue tant qu'un `#` n'est pas rencontré. Les faits commencent par `=` (ex: `=AB`), les requêtes par `?` (ex: `?ACD`). Les opérateurs supportés sont `!`, `+`, `|`, `^`, les parenthèses et les flèches `=>` ou `<=>`. En cas d'erreur de syntaxe, le parser s'arrête en indiquant la ligne fautive.

Exemple rapide : `examples/demo.exp` déduit `C: true, D: false, E: true` à partir de `A+B=>C`, `C|D=>E`, `A=>!D`, faits `=AB`, requêtes `?CDE`.

## Tests
Des cas d'usage rapides sont fournis dans `tests/` (simple implication, conflit A/!A, OR résolu avec branche fausse, XOR avec branche forcée). Lancer `tests/run_tests.sh` après compilation.

## Note
Le moteur applique les conclusions déterministes (symbole, !symbole, AND), gère les conflits A/!A en renvoyant `undetermined`, traite partiellement OR/XOR (si une branche est fausse ou vraie de façon certaine, l'autre est appliquée/niée), détecte le cas où les deux branches d'un OR sont forcées fausses, et itère jusqu'à stabilisation pour propager les nouvelles informations.

Mise à jour (2025-12-07 10:37:43) : Propagation ajustée (détection OR impossible, boucle évite oscillations), tests mis à jour (`xor_branch` conclut B faux si C vrai, cas OR double négation attend C/D faux), `make test` OK.
