# Philosophers

## Synthèse du projet
Simulation du problème des philosophes : plusieurs threads concurrents alternent entre « manger », « dormir » et « penser » tout en partageant des fourchettes protégées par des mutex.  
Le programme reçoit les paramètres temporels et un éventuel objectif de repas via la ligne de commande. Il s’arrête soit lorsqu’un philosophe meurt (dépassement du `time_to_die`), soit lorsque tous les philosophes ont mangé le nombre requis de fois.

## Paramètres d’exécution
```text
./philo number_of_philosophers time_to_die time_to_eat time_to_sleep [number_of_times_each_philosopher_must_eat]
```
- `number_of_philosophers` ≥ 1.
- Temps exprimés en millisecondes.
- Le paramètre optionnel impose une limite de repas pour chacun.

## Architecture
- `src/main.c` — parsing des arguments, initialisation et cycle global.
- `src/config.c` — conversions/validations des paramètres.
- `src/simulation.c` — allocation des ressources, gestion de l’état partagé.
- `src/run.c` — lancement des threads philosophes + thread moniteur.
- `src/philo.c` — routine d’un philosophe (ordre de prise des fourchettes, cycle manger/dormir/penser).
- `src/monitor.c` — surveillance centralisée des décès et du compteur de repas.
- `src/log.c` / `src/time.c` — horodatage milliseconde, journalisation protégée.
- `include/philo.h` — structures (`t_config`, `t_philo`, `t_sim`) et API interne.

## Synchronisation & Stratégie
- Chaque fourchette est un `pthread_mutex_t`.  
- Pour éviter l’interblocage : les philosophes impairs prennent d’abord la fourchette gauche, les pairs commencent par la droite (léger décalage initial pour les pairs).  
- Un mutex protège les mises à jour/consultations des temps de repas individuels.  
- Un thread moniteur vérifie en boucle :
  - dépassement du `time_to_die` → arrêt immédiat + log `died`;
  - seuil de repas atteint pour tous (si option présent) → arrêt propre.
- Les logs suivent le format `timestamp philosopher_id action` et sont sérialisés via un mutex dédié.

## Compilation
```sh
make            # construit le binaire philo
make clean      # supprime les objets intermédiaires
make fclean     # supprime objets + binaire
make re         # reconstruit proprement
```

## Exécution type
```sh
./philo 4 410 200 200
./philo 4 310 100 100 3
./philo 1 200 100 100   # cas mortel attendu
```

## Tests
- `./scripts/run_tests.sh` reconstruit le projet, exécute :
  1. un scénario nominal (`4 310 100 100 2`) sans décès attendu ;
  2. un scénario avec décès (`1 200 100 100`).
  Le script vérifie la présence/absence de `died` dans les logs et applique un timeout.
- Voir `tests_realisation/COMMANDS.md` pour les commandes manuelles supplémentaires.

## Ressources PDF
- `Sujet_Philosophers.pdf` — énoncé principal du module.
