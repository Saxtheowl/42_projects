# Philosophers – Scénarios de test

- `make re` — reconstruction complète du binaire `philo`.
- `./philo 4 310 100 100 2` — scénario nominal : 4 philosophes, tous doivent manger deux fois (aucun décès attendu).
- `./philo 1 200 100 100` — philosophe isolé, vérification du cas mortel.
- `./philo 5 800 200 200` — validation manuelle d’un run prolongé sans décès.
- `./scripts/run_tests.sh` — exécute automatiquement les cas ci-dessus (succès sans décès + décès attendu) avec contrôle de timeout.
