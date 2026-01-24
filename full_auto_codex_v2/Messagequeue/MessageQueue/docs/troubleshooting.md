# Troubleshooting

## API management 401/403
- Verifier `RABBITMQ_USER`/`RABBITMQ_PASS`.
- Si un vhost custom est utilise, definir `RABBITMQ_VHOST`.

## API management not reachable
- S'assurer que RabbitMQ est demarre (`docker compose ps`).
- Verifier le port 15672.

## Bindings manquants
- Relancer `./scripts/bootstrap_rabbitmq.sh`.
- Valider via `./scripts/validate_rabbitmq.sh`.

## Payload JSON invalide
- Si `publish_test_message.sh` affiche "Payload file is not valid JSON", verifier la syntaxe (accolades, virgules, guillemets).
- Revalider avec `./scripts/validate_payload.py` pour une verification locale rapide.
- En mode `--json`, une erreur renvoie `status=error`.

## Payload introuvable/dossier
- Si le message indique `Payload file not found` ou `Payload file is a directory`, verifier `PAYLOAD_FILE` et pointer un fichier JSON.

## --json sans python3
- En absence de `python3`, les erreurs ne peuvent pas etre encodees en JSON (sortie stderr).
- Verifier la presence de `python3` avec `command -v python3`.
- Installer `python3` si vous attendez une reponse JSON.

## Environnement
Voir `docs/troubleshooting_env.md`.
- Rappel: CONTENT_TYPE vide -> default, MESSAGE_ID vide -> default; MESSAGE_ID sans espaces/tabs/newlines, CONTENT_TYPE non blanc (espaces/tabs/newlines).
