# ft_strace

## Synthèse
Réimplémentation minimale de `strace` (sans options) qui intercepte les appels système d’un binaire Linux via `ptrace(2)`. Le programme affiche chaque syscall avec ses six registres arguments et la valeur de retour, gère les signaux et assure la compatibilité avec les binaires ELF 64 bits et 32 bits.

## Architecture & approche
- `Makefile` : construit `ft_strace` (C, libc autorisée) et régénère les tableaux d’appels système précompilés.
- `inc/ft_strace.h` : configuration de traçage et prototypes publics.
- `inc/syscall_table.h` + `src/syscall/*.c` : tables générées automatiquement de noms de syscalls (`asm/unistd_64.h` / `asm/unistd_32.h`) et fonction de lookup.
- `src/detect.c` : détection ELF 32/64 bits (fallback sur l’architecture hôte sinon).
- `src/trace.c` : boucle `ptrace` (`PTRACE_SETOPTIONS`, `PTRACE_SYSCALL`, `PTRACE_GETREGSET`), extraction des registres (`user_regs_struct`) et formatage des traces.
- `src/utils` (inclus) : gestion des zones d’arguments et mapping.
- `tests_realisation/` : scripts et tests `unittest` exécutant `ft_strace` sur `/bin/true` et `/bin/echo`.
- `Sujet_UNIX_Project.pdf` : lien vers le sujet officiel.

## Compilation & utilisation
```bash
make
./ft_strace /bin/ls -l
```

Le programme résout le binaire via `$PATH`, affiche chaque syscall et se termine par la ligne `+++ exited with <code> +++`.

## Tests
- `./tests_realisation/run_tests.sh` : `make re` puis tests Python (`test_ft_strace.py`).

## Répartition des PDF
- `Sujet_UNIX_Project.pdf` : sujet ft_strace (obligatoire).
