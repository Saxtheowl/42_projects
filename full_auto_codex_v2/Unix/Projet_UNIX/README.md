# Durex

## Synthèse
Implémentation éducative d’un trojan « Durex » conforme au sujet *Projet_UNIX.pdf*. Le binaire installe une copie de lui-même, crée un script de service et lance un démon TCP (port configurable) acceptant jusqu’à trois clients protégés par mot de passe (hash SHA-256). Une fois authentifié, l’utilisateur dispose d’un mini-interpréteur pouvant déclencher un shell distant.

## Architecture & approche
- `Durex` : binaire principal.
- `inc/` & `src/` :
  - `config.c` : lecture des variables d’environnement (`DUREX_PREFIX`, `DUREX_PORT`, `DUREX_ALLOW_UNSAFE`, `DUREX_PASSWORD[_HASH]`), calcul du hash SHA-256 et mise en place des chemins (`/bin`, `/etc/init.d`, `/var/run`, `/var/log`).
  - `run.c` : verrou PID, double fork, boucle `select` et gestion des clients (mot de passe, commandes, shell).
  - `sha256.c` : implémentation maison de SHA-256 (pas de mot de passe en clair).
- `tests_realisation/` : tests Python end-to-end exécutant le binaire avec un préfixe isolé et validant la connexion TCP.
- `Sujet_Projet_UNIX.pdf` : lien vers le sujet.

Pour rester dans un environnement contrôlé, les chemins de persistance sont préfixés par la variable `DUREX_PREFIX` (ex. dossier temporaire). Les tests activent `DUREX_ALLOW_UNSAFE=1` pour contourner l’exigence de privilèges root.

## Compilation & exécution
```bash
make               # construit Durex
DUREX_ALLOW_UNSAFE=1 DUREX_PREFIX=$PWD/sandbox DUREX_PASSWORD=secret ./Durex
```
Le programme imprime d’abord le login puis installe la copie et laisse tourner un démon en tâche de fond.

Connexion client (exemple) :
```bash
nc localhost 4242
Keycode: secret
$> help
$> shell
```

## Tests
- `./tests_realisation/run_tests.sh` : `make re` puis tests `unittest` (installation simulée et interaction réseau).

## Répartition des PDF
- `Sujet_Projet_UNIX.pdf` : sujet « Durex ».
