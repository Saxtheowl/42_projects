# ft_communication

## Synthèse
Le sujet ft_communication ne demande pas de développement réseau : il propose une série d’exercices (ex00 à ex02) visant à encourager les échanges entre étudiants en environnement distant. Ce dépôt fournit un kit prêt à l’emploi pour animer ces sessions : guide animateur, fiche participant, modèle de notes et un script CLI qui accompagne le déroulé.

## Contenu du dossier
- `docs/guide_animateur.md` — déroulé détaillé (préparation, animation, clôture).  
- `docs/fiche_participant.md` — aide-mémoire partagé avec les étudiants.  
- `docs/modele_notes.md` — template pour la prise de notes personnelle (non lue pendant la review).  
- `scripts/run_session.py` — assistant interactif pour suivre les exercices, avec export Markdown/JSON optionnel.  
- `scripts/run_tests.sh` — tests automatisés (aide + mode non interactif).  
- `tests_realisation/COMMANDS.md` — liste des commandes à exécuter (automatisées / manuelles).

## Utilisation
```sh
./scripts/run_session.py --participants "Alice,Bob"
```
- L’outil affiche les rappels pour chaque exercice et ponctue les étapes par des invites.  
- Option `--log notes.md` : génère un compte rendu Markdown (à conserver de manière privée).  
- Option `--non-interactif` : liste simplement les questions (utile pour préparer la session).  
- Option `--json recap.json` : écrit un résumé horodaté.

### Préparation conseillée
1. Lire `docs/guide_animateur.md`.  
2. Partager `docs/fiche_participant.md` avant la réunion.  
3. Préparer un créneau de 35-40 minutes et un espace confidentiel pour les notes.

## Tests
- Automatisés : `./scripts/run_tests.sh` (vérifie `--help` et `--non-interactif`).  
- Manuels : détaillés dans `tests_realisation/COMMANDS.md`.

## Points de vigilance
- Respecter la confidentialité : supprimer ou sécuriser les notes sauvegardées.  
- Prévoir un suivi post-session (ajout sur Slack, proposition de projets communs, etc.).  
- Norme 42 / valgrind non applicables (pas de code C) — seules des vérifications stylistiques simples sont proposées (PEP8 via `python -m compileall` si besoin).

## Prochaines étapes éventuelles
- Ajouter un minuteur intégré ou un export HTML (bonus).  
- Traduire les documents pour les campus non francophones.  
- Mutualiser les retours d’expérience dans un canal de communication dédié.
