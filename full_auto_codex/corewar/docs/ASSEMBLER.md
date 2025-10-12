# Spécification Assembler

## Format général
- Fichiers source `.s` encodés en UTF-8, chaque ligne contient :
  - Optionnellement un label `label:` (alphanum + `_`), suivi d’un espace ou tabulation.
  - Une instruction ou directive.
  - Optionnellement un commentaire introduit par `;` ou `#`.
- Les directives obligatoires :
  - `.name "<champion name>"` (jusqu’à 128 caractères).
  - `.comment "<description>"` (jusqu’à 2048 caractères).
- Les labels sont résolus en relative addressing (offset depuis PC de l’instruction courante).

## Pré-processeur minimal
- Pas de macros ni d’inclusion de fichiers.
- Une ligne peut contenir plusieurs espaces/tabs entre les tokens.
- Les nombres peuvent être :
  - décimaux (`42`, `-7`)
  - ou hexadécimaux (`0xFF`).

## Instructions
|	Opcode	|	Mnémonique	|	Args	|	Types autorisés	|	Cycles	|	Description	|
|--|--|--|--|--|--|
|0x01|`live`|1|`T_DIR` (4 octets)|10|Déclare qu’un joueur est vivant|
|0x02|`ld`|2|`T_DIR/T_IND`, `T_REG`|5|Charge|
|0x03|`st`|2|`T_REG`, `T_IND/T_REG`|5|Stocke|
|0x04|`add`|3|`T_REG`, `T_REG`, `T_REG`|10|Addition|
|0x05|`sub`|3|`T_REG`, `T_REG`, `T_REG`|10|Soustraction|
|0x06|`and`|3|`T_REG/T_DIR/T_IND`, `T_REG/T_DIR/T_IND`, `T_REG`|6|AND bit-à-bit|
|0x07|`or`|3|`T_REG/T_DIR/T_IND`, `T_REG/T_DIR/T_IND`, `T_REG`|6|OR bit-à-bit|
|0x08|`xor`|3|`T_REG/T_DIR/T_IND`, `T_REG/T_DIR/T_IND`, `T_REG`|6|XOR bit-à-bit|
|0x09|`zjmp`|1|`T_DIR` (2 octets)|20|Saut conditionnel (carry)|
|0x0a|`ldi`|3|`T_REG/T_DIR/T_IND`, `T_REG/T_DIR`, `T_REG`|25|Charge indirect (mod IDX_MOD)|
|0x0b|`sti`|3|`T_REG`, `T_REG/T_DIR/T_IND`, `T_REG/T_DIR`|25|Stock indirect (mod IDX_MOD)|
|0x0c|`fork`|1|`T_DIR` (2 octets)|800|Duplique le processus (mod IDX_MOD)|
|0x0d|`lld`|2|`T_DIR/T_IND`, `T_REG`|10|Load sans mod|
|0x0e|`lldi`|3|`T_REG/T_DIR/T_IND`, `T_REG/T_DIR`, `T_REG`|50|Load indirect sans mod|
|0x0f|`lfork`|1|`T_DIR` (2 octets)|1000|Fork sans mod|
|0x10|`aff`|1|`T_REG`|2|Affiche caractère|

- `T_DIR` vaut 2 octets pour les instructions marquées (IDX_MOD), 4 sinon.
- L’octet de codage (ACB) est présent pour toutes les instructions sauf : `live`, `zjmp`, `fork`, `lfork`.

## Header et Bytecode
- Magic number : `0x00EA83F3` (big endian).
- Structure `header_t` :
  ```c
  typedef struct s_header {
      unsigned int magic;
      char name[PROG_NAME_LENGTH + 1];
      unsigned int prog_size;
      char comment[COMMENT_LENGTH + 1];
  } header_t;
  ```
- Champ `prog_size` rempli après la deuxième passe.
- Le code suit immédiatement les 4 octets de padding entre `name` et `comment`, puis 4 octets de padding avant le code (selon op.h original).

## Résolution des labels
1. Première passe :
   - Calcul des tailles d’instruction pour connaître la position (PC) de chaque label.
   - Vérification de la validité des arguments (`r1`..`r16`, type autorisé).
2. Deuxième passe :
   - Écriture du header puis du code.
   - Remplacement des références `:%label` par `(label_pc - current_pc)` avec modulo `IDX_MOD` si instruction type "index".

## Gestion des erreurs
- Doublon de label, label inconnu.
- Dépassement du nombre maximum de registres.
- Taille > `CHAMP_MAX_SIZE`.
- Syntaxe invalide -> message explicite avec numéro de ligne.

## CLI attendue
```
usages: ./asm <file.s>
        ./asm -o output.cor file.s
        ./asm --show-tokens file.s (option de debug)
```
