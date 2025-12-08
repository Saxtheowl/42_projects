
# Format des fichiers machine

- `states:` liste d'états séparés par des virgules.
- `alphabet:` alphabet de travail (caractères sans virgule). Le symbole de blanc doit y figurer.
- `blank:` symbole utilisé pour les cases vides (ex: `_`). Obligatoire, d'un seul caractère, et doit appartenir à l'alphabet.
- `initial:` état initial.
- `accept:` liste d'états acceptants (optionnelle).
- Transitions : `q_current read -> q_next write move` où `move` est `L` ou `R`.
- Commentaires : `#` en début de ligne.

Sections obligatoires : `states`, `alphabet`, `blank`, `initial`. Le validateur refuse les fichiers où l'une de ces sections manque.
Une transition ne doit pas contenir de tokens supplémentaires au-delà des 6 attendus.

Option `-c` (complétude) : vérifie que chaque état non-acceptant possède une transition pour chaque symbole de l'alphabet (y compris le blanc). Utile pour s'assurer que la machine est totale.

Exemple minimal :
```
states: q0,q1,qacc
alphabet: a_
blank: _
initial: q0
accept: qacc
q0 a -> q1 a R
q1 _ -> qacc _ R
```
