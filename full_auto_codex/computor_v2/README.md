# Computor v2 – Mini Interpréteur Mathématique

## Synthèse
- Interpréteur interactif gérant assignations de variables, nombres complexes (sans `std::complex`) et matrices.
- Prend en charge les opérations `+`, `-`, `*`, `/`, les parenthèses et quelques fonctions (`sin`, `cos`, `tan`, `exp`, `log`, `sqrt`).
- Matrices définies via `[[a, b]; [c, d]]` avec opérations +, -, *, division par scalaire et addition/soustraction d'un scalaire.

## Fonctionnement
- Chaque ligne saisie est soit une expression, soit une affectation `variable = expression`.
- Les valeurs sont mémorisées dans l’environnement pour être réutilisées (la constante `i` est pré-définie).
- Les résultats sont affichés en sortie standard; les erreurs de syntaxe/typage sont signalées.

## Compilation
```sh
make
```
Génère le binaire `computor_v2`.

## Utilisation
Lancement du REPL :
```sh
./computor_v2
>> z = 2 + 3i
z = 2.000000 + 3.000000i
>> m = [[1, 2]; [3, 4]]
m = [[1.000000, 2.000000]; [3.000000, 4.000000]]
>> m * z
[[2.000000 + 3.000000i, 4.000000 + 6.000000i]; [6.000000 + 9.000000i, 8.000000 + 12.000000i]]
```

## Tests
```sh
python3 tests_realisation/run_tests.py
```
- Compile l’outil puis exécute quelques scénarios automatiques (nombres complexes, matrices, erreurs de portée).
