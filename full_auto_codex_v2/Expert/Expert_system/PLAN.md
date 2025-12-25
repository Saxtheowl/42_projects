# Plan Expert_system

## Court terme
- [ ] Ajout d'un fixpoint global sur l'ensemble des symboles avant les requêtes (propagation complète OR/XOR imbriqués).
- [ ] Étendre la détection des contradictions multiples et des cycles complexes.
- [ ] Enrichir la suite de tests avec des cas imbriqués (OR de XOR, doubles implications).
- [ ] Générer un rapport synthétique des déductions (trace optionnelle) pour le debug.
- [ ] Couvrir les cas mixtes (OR/XOR imbriqués avec négations) et vérifier la cohérence des conflits multiples.

## Réalisé récemment
- [x] Propagation OR avec branche fausse et détection OR impossible.
- [x] Jeu de tests automatisé (5 cas) + cible `make test`.
- [x] Exemple de démonstration `examples/demo.exp`.
