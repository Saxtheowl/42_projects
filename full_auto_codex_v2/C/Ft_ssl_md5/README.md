# ft_ssl_md5

Dernière mise à jour (2025-12-26 02:17:52) : CLI complète md5/sha256 (-p/-q/-r/-s, fichiers), gestion erreurs/usage (commande/option inconnue, -s manquant), cache stdin partagé, suite d’autotests `make test`; projet terminé.

## Usage
```bash
./ft_ssl md5 [-p] [-q] [-r] [-s string] [files...]
./ft_ssl sha256 [-p] [-q] [-r] [-s string] [files...]
```

## Build
```bash
make
```

## Tests
```bash
make test
```

## Notes
- Implémentation MD5/SHA256 pure C (fichiers `src/md5.c` / `src/sha256.c`).
- Options supportées : `-q` (quiet), `-r` (reverse), `-p` (echo stdin puis digest), `-s` (string, répétable), fichiers en argument. Sans fichiers ni `-s`, lit `stdin`.
- Le script de tests compare l’output à `md5sum`/`sha256sum` pour plusieurs cas (strings, fichiers, stdin, `-p`).
