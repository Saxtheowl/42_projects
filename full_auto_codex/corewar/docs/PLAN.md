# Corewar – Plan de Travail

## 1. Analyse & Spécification
- [x] Formaliser la grammaire de l’assembleur (.s) : directives (.name/.comment), labels, instructions, commentaires. *(cf. `docs/ASSEMBLER.md`)*
- [x] Documenter le header binaire (magic number, taille du programme, nom/commentaire) et l’endianness. *(cf. `docs/ASSEMBLER.md` + `include/op.h`)*
- [x] Recenser les 16 instructions (opcode, arguments, codage ACB, cycles, effet sur carry/PC). *(cf. `docs/ASSEMBLER.md`)*
- [x] Définir les constantes globales : mémoire (4096 octets), IDX_MOD, cycle_to_die, etc. *(cf. `include/op.h`)*

## 2. Assembleur
- [x] Parser lexical (tokenizer initial) avec option `--show-tokens`.
- [ ] Parser syntaxique (instructions, directives) → structure intermédiaire.
- [ ] Résolution des labels (1 ou 2 passes) et calcul des décalages (mod IDX_MOD si nécessaire).
- [ ] Génération du bytecode (header + code) et gestion des erreurs (argument invalide, dépassement de taille).
- [ ] Outils : mode verbose, désassembleur optionnel.

## 3. Machine Virtuelle
- [ ] Structure `process` (registre[16], PC, carry, cycles_to_exec, player_id).
- [ ] Mémoire circulaire (tableau d’octets) + carte des propriétaires pour l’affichage.
- [ ] Ordonnanceur : boucle principale -> decrease cycles, exécuter instruction quand prête, gérer `cycle_to_die`.
- [ ] Implémentation de chaque opcode (manipulation mémoire, Mod IDX_MOD, sauts, creation/destruction process via `fork`/`lfork`).
- [ ] Interface : mode texte (affichage des cycles, processus, gagnant).

## 4. Champions & Tests
- [ ] Construire quelques champions de test (live-loop, basic bomber, etc.).
- [ ] Scripts automatisés : assembler → vm (diff attendu), tests d’intégration.
- [ ] Comparaison avec la VM de référence si disponible.

## 5. Bonus (après validation)
- [ ] Interface graphique (ncurses ou SDL).
- [ ] Mode réseau.
- [ ] IA generative à partir de templates de champions.

---
*Dernière mise à jour : TODO*
