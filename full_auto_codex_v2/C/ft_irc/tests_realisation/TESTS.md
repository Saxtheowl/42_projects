# Smoke test ft_irc

Ce dossier contient un test de fumee automatise base sur des sockets locales.

## Execution

- `python3 tests_realisation/run_smoke.py`
  - Lance `ircserv` sur un port libre, connecte trois clients TCP et verifie les commandes IRC de base.
  - Si les sockets locales sont interdites, le test s'arrete avec un message "Skipping smoke test".

## Notes

- Le test depend d'un environnement autorisant les sockets TCP locales.
- Le binaire `ircserv` doit etre compile (`make`) avant execution.
