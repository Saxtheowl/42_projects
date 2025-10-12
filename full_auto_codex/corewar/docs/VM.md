# Machine Virtuelle – Spécification

## Constantes clés
- `MEM_SIZE = 4096`
- `IDX_MOD = 512`
- `MAX_PLAYERS = 4`
- `REG_NUMBER = 16`
- `CYCLE_TO_DIE = 1536`, `CYCLE_DELTA = 50`, `NBR_LIVE = 21`

## Structures de données
```c
typedef struct s_process {
    int pid;                // identifiant unique
    int pc;                 // position courante dans l’arène (0..MEM_SIZE-1)
    int last_live_cycle;    // cycle du dernier LIVE exécuté
    int carry;              // flag carry
    int wait_cycles;        // cycles restants avant exécution
    int registers[REG_NUMBER + 1]; // registre[1..16]
    int owner;              // id du joueur
} t_process;

typedef struct s_player {
    int id;
    char name[PROG_NAME_LENGTH + 1];
    char comment[COMMENT_LENGTH + 1];
    int size;
    unsigned char *code;    // taille size
    int last_live_cycle;
} t_player;
```
- Arène : `unsigned char arena[MEM_SIZE];`
- "Carte" (option affichage) : `int ownership[MEM_SIZE];`

## Boucle principale
1. Initialisation :
   - Charger les programmes équitablement dans l’arène (espacés de `MEM_SIZE / nb_players`).
   - Créer un process par joueur.
2. Cycle :
   - Pour chaque process :
     - Si `wait_cycles <= 0` : lire opcode, déterminer cycles requis, valider arguments.
     - Décrémenter `wait_cycles`.
     - Quand `wait_cycles == 0` → exécuter l’instruction, avancer `pc` (sauf saut) et appliquer `IDX_MOD` si besoin.
   - Incrémenter compteur de cycles globaux.
   - Après `cycle_to_die` cycles :
     - Supprimer les process n’ayant pas exécuté `live` depuis `cycle_to_die`.
     - Si le nombre de `live` >= `NBR_LIVE` → décrémenter `cycle_to_die` de `CYCLE_DELTA`.
     - Réinitialiser compteur `live`.
3. Fin :
   - Lorsque plus qu’un seul joueur (ou aucun process) reste, déclarer le dernier ayant fait `live`.

## Parsing des arguments
- Utiliser l’ACB pour déterminer types : `00` (absent), `01` (reg), `10` (dir), `11` (ind).
- `T_REG` → 1 octet; `T_IND` → 2 octets; `T_DIR` → taille dépendante (2 ou 4).
- Vérifier les limites (`1 <= reg <= REG_NUMBER`).

## Instructions
- Implémenter 16 opcodes avec respect des cycles et effets :
  - `live`: note le joueur vivant.
  - `ld`, `lld`: chargement (carry = (val == 0)).
  - `st`: stockage (vers registre ou mémoire via IDX_MOD).
  - `add`, `sub`: opérations arithmétiques sur registres.
  - `and`, `or`, `xor`: opérations logiques (carry).
  - `zjmp`: PC = `PC + (arg % IDX_MOD)` si carry == 1.
  - `ldi`, `lldi`: chargement indirect (mod ou non).
  - `sti`: écriture indirecte.
  - `fork`, `lfork`: duplication de process avec PC offset (mod ou non).
  - `aff`: afficher char `reg[1] % 256` (mode debug).

## Interface
- `./corewar [-dump cycle] [-v] [-n number] champion1.cor [...]`
- Options :
  - `-dump`: affiche mémoire et termine.
  - `-v`: mode verbose (live, cycle_to_die, opérations).
  - `-n`: force l’ID d’un joueur.

## Affichage / Debug
- Mode texte minimal :
  - Afficher cycles, nombre de process, champion gagnant.
  - Commandes `-logs` pour détailler chaque action.
- Bonus ncurses : visualisation temps réel de l’arène.
