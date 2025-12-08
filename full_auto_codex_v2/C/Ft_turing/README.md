# ft_turing

## Synthèse actuelle
Sujet 42 « ft_turing » : implémenter un vérificateur/simulateur de machine de Turing. Charger une description (états, alphabet, transitions), valider sa cohérence, exécuter pas à pas avec limite pour éviter les boucles, option verbose pour tracer transitions et ruban.

## État actuel
- PDF copié dans `docs/Ft_turing.pdf`.
- Makefile + squelette en C++17 (`ft_turing`) : parser (états, alphabet, initial, acceptants, blank obligatoire et unique, transitions `q a -> q' b M`), simulateur avec limite de pas, option verbose, CLI `./ft_turing <machine> <input> [-v] [-t] [-s max_steps]`.
- Validation des transitions : états connus, symboles dans l'alphabet ou blank, mouvements L/R, blank obligatoire déclaré et présent dans l'alphabet, sections `states/alphabet/blank/initial` obligatoires.
- Exemples : `examples/unary_increment.tm` (incrémente un unaire) et `examples/reject_even.tm` (accepte seulement les longueurs impaires) ; `loop.tm` (max_steps) ; cas invalides (`bad_input.tm`, `invalid_duplicate.tm`, `invalid_move.tm`, `invalid_missing_blank.tm`, `invalid_missing_states.tm`, `invalid_missing_alphabet.tm`, `invalid_missing_initial.tm`, `invalid_transition_extra_tokens.tm`, `invalid_unknown_state.tm`).
- Script de tests : `examples/run_tests.sh` (compilation requise), couvre accept/reject et validations (13 cas).

## Plan provisoire
1) Lire le sujet et ajuster encore les messages d'erreur attendus (alignement complet avec le PDF si besoin).
2) Ajouter des machines de test supplémentaires (transitions manquantes, halt explicite) et scénarios de validation.
3) Finaliser la CLI/format (expliquer -t, limiter taille du ruban) et documenter les codes de retour.

## Journal
- 2025-12-08 22:14:12 : blank rendu obligatoire (erreurs dédiées), CLI documentée avec `-t`, ajout du test `invalid_missing_blank.tm` et docs/README/examples mis à jour.
- 2025-12-08 22:19:06 : couverture de validation étendue (sections obligatoires states/alphabet/blank/initial testées), suite de tests portée à 12 cas, docs/README actualisés.
- 2025-12-08 22:22:44 : détection des tokens superflus sur une transition, nouveau test `invalid_transition_extra_tokens.tm`, suite portée à 13 cas.
