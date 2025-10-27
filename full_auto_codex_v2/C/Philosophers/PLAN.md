# Plan de mise en œuvre Philosophers

## Étape 1 – Analyse
- [x] Lire `Sujet_Philosophers.pdf` / consolider les exigences du sujet (format, timings, états).
- [x] Identifier paramètres CLI (nombre philosophes, temps, nb repas).
- [x] Lister comportements attendus (messages, états, timing).

## Étape 2 – Infrastructure
- [x] Structurer arborescence `src/`, `include/`, `tests_realisation/`, `scripts/`.
- [x] Mettre en place `Makefile` (targets `philo`, `bonus` si requis).
- [x] Définir structures partagées (`t_philo`, `t_simulation`, mutex, etc.).

## Étape 3 – Implémentation de base
- [x] Parser arguments et initialiser contexte.
- [x] Créer threads (un par philosophe) + mutex fourchettes.
- [x] Implémenter routine philosophes (penser, manger, dormir) avec suivi temps.

## Étape 4 – Synchronisation & Surveillance
- [x] Implémenter surveillance (détection décès).
- [x] Gérer arrêt propre (mutex, threads).
- [x] Implémenter limite de repas si paramètre fourni.

## Étape 5 – Outils & Tests
- [x] Écrire `README.md` (synthèse, architecture, build/run).
- [x] Scripts tests (scénarios standard, stress, edge cases).
- [x] Ajouter support logging format du sujet.

## Étape 6 – Bonus (si demandé)
- [ ] Philosophiers bonus (threads vs processes, semaphores).
- [ ] Tests dédiés.

## Étape 7 – Validation
- [x] Tests manuels + automatisés (timings).
- [ ] Valgrind/ASan si disponibles — outil indisponible sur l’environnement courant (à relancer ultérieurement).
- [ ] Norme 42 — vérification automatique Norminette à rejouer dès qu’installée.
