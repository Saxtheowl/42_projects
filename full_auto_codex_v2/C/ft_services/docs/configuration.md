# Configuration ft_services

Le service lit un fichier clé/valeur (`port=`, `backlog=`, `log_path=`) par défaut à `/etc/ft_services.conf`, mais on peut surcharger avec `--config`. Options :

- `port` : port TCP (>1024). Contrôlé par `scripts/validate_config.py`.
- `backlog` : taille de la file d'attente `listen`. Doit être un entier strictement positif.
- `log_path` : chemin du fichier de log; le service crée automatiquement le répertoire parent.
- `welcome` : message TCP renvoyé à chaque client (`STATUS` reçoit `STATUS: OK`).
- `max_connections` : limite optionnelle après laquelle la réponse devient `overloaded: <n>` et un événement `connection limit reached` est journalisé.

### Exemple
```
port=4242
backlog=16
log_path=/var/log/ft_services/ft_services.log
welcome=ft_services says hello
```

Utilisez `scripts/validate_config.py --config` pour vérifier rapidement ce fichier, `scripts/check_env.sh` pour vous assurer que le répertoire/log existent, `scripts/check_status.sh` pour dispatcher `STATUS` vers le démon (réponse `STATUS: OK`), et `scripts/wait_for_status.sh` lorsque le service démarre afin de patienter jusqu’à ce qu’il accepte les vérifications de santé.
