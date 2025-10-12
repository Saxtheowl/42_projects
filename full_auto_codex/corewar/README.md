# Corewar – Architecture Overview

Ce répertoire contient les bases du projet **Corewar** :

- `assembler/` : compilera un champion écrit en assembleur Corewar en bytecode (tokenizer initial disponible via `--show-tokens`).
- `vm/` : machine virtuelle qui chargera plusieurs champions et simulera l’arène (mémoire circulaire, processus, règles de cycle).
- `champions/` : exemples de programmes assembleur et leurs bytecodes.
- `docs/` : notes de conception, références et journal d’avancement.

## Travail restant
- Rédiger la spécification détaillée de l’assembleur (syntaxe, tableau `op_tab`, format d’en-tête, encodage des arguments).
- Définir la représentation interne de la VM (mémoire, processus, gestion des cycles, gestion des "live").
- Implémenter l’ensemble des opcodes et vérifier les délais (cycle delay).
- Construire une suite de tests : assembleur ↔ bytecode, exécution de champions simples, batailles multi-champions.

Les détails sont esquissés dans `docs/PLAN.md`.
