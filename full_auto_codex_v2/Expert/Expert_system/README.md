# Expert system

## Synthese
Implémenter un moteur d'inférence (backward chaining) pour le calcul propositionnel. Entrée : fichier texte décrivant des règles (A + B => C, etc.), faits initiaux (=ABG), requêtes (?XYZ). L'engine doit répondre vrai/faux/indéterminé pour chaque requête (support AND, OR, XOR, NOT, parenthèses, règles multiples, AND en conclusion; bonus: OR/XOR en conclusion, biconditionnel, interaction). Erreurs d'entrée doivent être signalées.

## Avancement
- [x] Copie du sujet (`docs/Expert_system.pdf`) et lecture complète des exigences (backward-chaining, format fichier, opérateurs + | ^ ! => <=>, commentaires #).
- [x] Squelette projet + parser complet (règles/faits/requêtes), moteur backward-chaining avec fixpoint global.
- [x] Support OR/XOR imbriqués, biconditionnel déplié, contradictions A/!A (faits ou règles) marquées en conflits, rétro-propagation des conflits (OR impossible, XOR contradictoire).
- [x] Options CLI combinables : `-v` (trace + faits), `-c` (conflits), `-s` (résumé), `-o` (origine des conflits), `-j` (sortie JSON des requêtes, compatible -o).
- [x] Suite de tests automatisés (17 cas : implications, conflits, OR/XOR, bicond, faits négatifs/contradictoires, trace, origines, JSON) validée par `make test`.

## Usage
```sh
make
make test                        # lance les tests dans tests/run_tests.sh
./expert [-v] [-c] [-s] [-o] [-j] <input_file>  # -v trace les règles et affiche les faits connus, -c affiche les conflits, -s affiche un résumé des valeurs, -o affiche l'origine des conflits sur chaque requête, -j exporte les réponses en JSON (flags combinables : -vcoj)
```
Chaque ligne de règle est lue tant qu'un `#` n'est pas rencontré. Les faits commencent par `=` (ex: `=AB`), les requêtes par `?` (ex: `?ACD`). Les opérateurs supportés sont `!`, `+`, `|`, `^`, les parenthèses et les flèches `=>` ou `<=>`. En cas d'erreur de syntaxe, le parser s'arrête en indiquant la ligne fautive.

Exemple rapide : `examples/demo.exp` déduit `C: true, D: false, E: true` à partir de `A+B=>C`, `C|D=>E`, `A=>!D`, faits `=AB`, requêtes `?CDE`. Un préfixe de fixpoint global est appliqué sur les symboles présents dans règles/requêtes avant d'afficher les réponses.

## Tests
Des cas d'usage rapides sont fournis dans `tests/` :
- `simple_implication.exp`
- `conflict.exp` (A et !A)
- `or_resolution.exp` (branche fausse -> l'autre vraie)
- `xor_branch.exp` (branche forcée)
- `or_conflict.exp` (double négation)
- `xor_conflict.exp` (B ^ C et !B/!C)
- `bicond.exp` (A <=> B)
- `xor_mixed.exp` (OR de XOR avec négations croisées)
- `demo.exp` (exemple complet)
- `bicond_chain.exp` (chaînage A<=>B<=>C avec faits sur A)
- `neg_fact.exp` (fait initial négatif `=!A`)
- `facts_conflict.exp` (faits initiaux contradictoires =A!A)
- `trace_conflict_input.exp` (détecte et trace un conflit via `-v`)
- `or_conflict_origin.exp` (conflit OR impossible; vérifié avec `-c`, `-o` et `-co`)
- `simple_implication.exp` (couvert aussi en sortie JSON avec `-j`)
Lancer `tests/run_tests.sh` après compilation ou `make test`.

## Note
Le moteur applique les conclusions déterministes (symbole, !symbole, AND), gère les conflits A/!A en renvoyant `undetermined`, traite partiellement OR/XOR (si une branche est fausse ou vraie de façon certaine, l'autre est appliquée/niée), détecte le cas où les deux branches d'un OR sont forcées fausses, et itère jusqu'à stabilisation pour propager les nouvelles informations.

Mise à jour (2025-12-07 10:37:43) : Propagation ajustée (détection OR impossible, boucle évite oscillations), tests mis à jour (`xor_branch` conclut B faux si C vrai, cas OR double négation attend C/D faux), `make test` OK.

Mise à jour (2025-12-08 20:08:12) : Ajout de `-j` (export JSON des requêtes, avec origine si `-o`), flags combinables (`-vcoj`), test JSON ajouté, suite portée à 17 cas; `make test` OK.
