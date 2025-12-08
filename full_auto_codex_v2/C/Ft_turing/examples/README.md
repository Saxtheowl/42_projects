# Exemples

- `unary_increment.tm` : ajoute un symbole `a` au bout d'une chaîne unaire. Utilisation : `./ft_turing examples/unary_increment.tm aaaa -v` (attendu: ACCEPT, ruban ~ aaaaa).
- On peut écrire le ruban final dans un fichier avec `-o out.txt`.
- `reject_even.tm` : accepte les longueurs impaires uniquement. Utilisation : `./ft_turing examples/reject_even.tm aa` (REJECT) et `./ft_turing examples/reject_even.tm aaa` (ACCEPT).
- Invalides pour tests de validation :
  - `bad_input.tm` : symbole lu non présent dans l'alphabet.
  - `invalid_duplicate.tm` : doublon de transition pour un même état/symbole.
  - `invalid_move.tm` : mouvement interdit (ni L ni R).
  - `invalid_unknown_state.tm` : transition vers un état inexistant.
  - `invalid_missing_blank.tm` : absence de symbole de blanc déclaré.
  - `invalid_blank_not_in_alphabet.tm` : blank non présent dans l'alphabet.
  - `invalid_missing_states.tm` : section `states:` absente.
  - `invalid_missing_alphabet.tm` : section `alphabet:` absente.
  - `invalid_missing_initial.tm` : section `initial:` absente.
  - `invalid_transition_extra_tokens.tm` : transition avec des tokens superflus.
  - `invalid_missing_transition.tm` : transition manquante (détectée seulement avec l'option `-c`; ou en exécution via `-r` pour afficher la raison d'arrêt).
- Pour démontrer la limite de pas et la raison d'arrêt : `loop.tm` avec `-s 2 -r` affiche "max steps reached".
