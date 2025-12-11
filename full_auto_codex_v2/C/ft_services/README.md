# ft_services

Ce dossier contient l'analyse et la préparation du projet **ft_services** (voir `/home/roro/work/projects/All-42-subject/organized_subjects/C/ft_services.pdf`). Le sujet porte sur la création d'un service autonome (probablement un démon réseau ou un service systemd) avec des obligations de résilience, de configuration et de tests.

`src/main.c` lit `port`, `backlog`, `log_path`, et `welcome` depuis `/etc/ft_services.conf` (ou `--config`). Il crée les répertoires de log, écrit `start`/`stop` dans ce journal, gère SIGINT/SIGTERM, et fixe `port` à 4242/backlog à 10 par défaut. Le service écoute en TCP, consigne chaque connexion, répond avec le message `welcome` (par défaut "ft_services says hello"), réagit à la commande `STATUS` en envoyant `STATUS: OK`, et journalise `status check` pour montrer que les vérifications réseau sont tracées à la revue ft_services.

### Vérification de santé
- `scripts/check_status.sh [config]` lit le port (`tests/env/ft_services.conf` par défaut), envoie `STATUS`, et attend `STATUS: OK`. Ce helper permet de démontrer à la revue que le démon répond sur le réseau lorsqu’il est démarré localement.
- `scripts/wait_for_status.sh [config [tries [delay]]]` relance `check_status.sh` tant que le démon n’a pas retourné `STATUS: OK`, ce qui simplifie l’attente d’un service en cours de démarrage dans les pipelines de revue ft_services.
- `scripts/query_count.sh [config]` envoie `COUNT` au démon et affiche `connections: <n>`, fournissant à la revue la trace du nombre de clients servis (utile pour monitorer la charge après `wait_for_status`).
- `scripts/test_max_connections.sh [config [max]]` pousse `STATUS` `max` fois pour forcer la réponse `overloaded: <n>` quand `max_connections` est configuré.

#### Règles de conduite pour les scripts
1. **Démarrage en premier** : lancez toujours le binaire (avec `tests/env/ft_services.conf` ou `tests/env/ft_services_status.conf` si vous voulez vérifier `max_connections`) avant de toucher aux helpers ; la socket doit être disponible (port 4242 par défaut) pour que `check_status.sh`/`wait_for_status.sh` réussissent.
2. **Étager les vérifications** : faites un `wait_for_status.sh` pour confirmer la santé, puis utilisez `query_count.sh` pour constater le nombre de connexions. Enfin, lancez `test_max_connections.sh` **via le fichier `tests/env/ft_services_status.conf`** (ou la copie équivalente) afin d’exercer `max_connections` et obtenir `overloaded: <n>` sans perturber une session de production.
3. **Remise à zéro des traces** : après chaque jeu de scripts, supprimez l’ancien log (`log_path` dans la config courante, `tests/env/ft_services.conf` écrit par défaut dans `/tmp/ft_services.log`) pour éviter que les revues lisent un fichier saturé. Un `rm -f /tmp/ft_services.log` ou le chemin explicité dans votre config suffit avant de redémarrer le démon pour une nouvelle campagne de tests.
4. **Utiliser `scripts/clean_log.sh`** : si votre configuration pointe vers un autre `log_path`, passez-le en argument au helper `scripts/clean_log.sh path/to/config` pour effacer (et recréer) le fichier de log proprement. Cela évite d’avoir à deviner où la configuration place le journal tout en garantissant que la revue puisse redémarrer le service avec un log vierge.

#### Script de séquence complète
`scripts/monitor_status.sh [config [max]]` enchaîne `clean_log.sh`, `wait_for_status.sh`, `query_count.sh` et `test_max_connections.sh` pour vérifier en une commande la santé, le compteur et la limite de connexions. Le second argument indique combien de `STATUS` il faut pousser pour déclencher `overloaded: <n>` (par défaut 10 ou `MAX_CONNECTIONS`). Ce script facilite les démonstrations rapides et force l’injection de `max_connections` pendant que les autres helpers font leurs vérifications.

#### Astuce de démonstration
1. Lancez `./ft_services --config tests/env/ft_services_status.conf` dans une fenêtre pour activer `max_connections` (l’exécutable se trouve dans `C/ft_services/ft_services/`).
2. Dans une seconde fenêtre, exécutez `scripts/monitor_status.sh tests/env/ft_services_status.conf 15` pour nettoyer le log, valider la santé, regarder le compteur et atteindre la limite (15 `STATUS` envoyés) en un seul passage.
3. Pour inspecter les paramètres avant/pendant la démonstration, lancez `scripts/show_config.sh tests/env/ft_services_status.conf` afin de confirmer `port`, `backlog`, `log_path` et `max_connections`.
4. Ensuite, envoyez des commandes en direct avec `scripts/client_demo.py --config tests/env/ft_services_status.conf --commands STATUS COUNT STATUS` pour montrer chaque requête et réponse `connections: <n>`.
5. Vous pouvez relancer `scripts/clean_log.sh tests/env/ft_services_status.conf` entre deux sessions pour repartir sur un journal propre.
6. Pour automatiser la démonstration sur plusieurs configurations, lancez `scripts/demo_pipeline.sh tests/env/ft_services_status.conf tests/env/ft_services.conf` afin d’exécuter show_config/clean_log/monitor_status pour chaque fichier et valider la santé US/COUNT/overload en chaîne.

Consultez `docs/helpers.md` pour un résumé de tous les helpers et de l’ordre recommandé.

#### Scripts utilitaires complémentaires
`scripts/show_config.sh [config]` affiche les valeurs `port`, `backlog`, `log_path` et `max_connections` extraites d’une configuration, ce qui aide à s’assurer que les helpers utilisent les mêmes paramètres que le service lui-même sans avoir à relire manuellement le fichier.
`scripts/stress_max_connections.sh [config [max]]` envoie `STATUS` en boucle via `nc` (POSIX) pour atteindre `overloaded: <n>` et peut être utilisée pour valider que `max_connections` se déclenche sur charge ; le second argument contrôle le nombre d’essais avant d’abandonner.
## Objectifs de démarrage
- Traduire les exigences du PDF en listes de tâches (initialisation, configuration, sécurité, tests).
- Documenter l'approche (architecture, composants, scripts d'automatisation) dans `PLAN.md`.
- Créer des scripts de prép (shell/python) pour l'évaluation (tests unitaires, check de configuration) et un README pour décrire l'usage.
- Créer des scripts de prép (shell/python) pour l'évaluation (tests unitaires, check de configuration) et un README pour décrire l'usage.
- Décrire `src/main.c` + `src/args.c` qui acceptent `--config <path>` en override de `/etc/ft_services.conf` pour tester différents fichiers facilement.
- Ajouter `scripts/run_tests.sh` qui compile `src/main.c` et valide l’environnement, afin de pouvoir exécuter un pipeline rapide pendant la revue.
- Ajouter un `Makefile` pour compiler `src/main.c` via `make` et nettoyer via `make clean`, ce qui complète le workflow de build/tests.
- Implémenter un squelette minimal (`src/main.c`) qui gère SIGINT/SIGTERM pour préparer la structure du démon.

## Prochaines étapes
1. Examiner le PDF pour extraire les sections obligatoires (ex: fichiers à produire, contraintes réseau, options configuration) et les noter dans `PLAN.md`.
2. Esquisser un framework de scripts pour la surveillance du service (lint, tests unitaires, validation de configuration) afin de pouvoir réagir rapidement durant la revue.
3. Commencer l'implémentation en priorisant les parties critiques (ex: parsing, networking, sécurité) une fois la structure documentée.

### Vérification d'environnement
- `scripts/check_env.sh` teste la présence des fichiers de configuration attendus (`/etc/ft_services.conf`, `/etc/ft_services`, log) et échoue si l'un d'entre eux manque, facilitant l'intégration continue lors de la revue ft_services.
- `scripts/validate_config.py` analyse un fichier config (`--config`) et vérifie que le port est dans [1024,65535] et le backlog positif, créant une autre validation rapide pour la revue.
Consultez [docs/configuration.md](docs/configuration.md) pour voir l’exemple complet de fichier configuration (port/backlog/log_path), puis lancez `scripts/validate_config.py --config` ou `bash scripts/run_tests.sh` avant la revue.

### Générateur de configuration
- `scripts/gen_config.py` produit un fichier de configuration par défaut (`tests/env/ft_services.conf`) avec port/backlog/log_path prêts pour les tests, ce qui simplifie la préparation d’une revue sans toucher `/etc`.

### Logging
- `src/log.c` expose `log_event()` pour enregistrer les événements `start`/`stop` avec un horodatage dans `log_path` (créé automatiquement). Le main utilise ce module pour garder une trace lisible de la durée de vie du service.
