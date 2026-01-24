# Contrat API pour `publish_test_message`

Ce document rassemble les exigences du POST JSON que les scripts de tests et la documentation (local_usage, troubleshooting, quickstart) mentionnent : tous les champs doivent respecter longueur, regex et espace/retour à la ligne.

## Champs requis

| Champ | Description | Contraintes |
| --- | --- | --- |
| `exchange` | Nom de l'exchange RabbitMQ ciblé | 1-32 caractères, regex `[a-z0-9_.-]+` |
| `routing_key` | Clé de routage utilisée par le producer | 1-32 caractères, même regex |
| `doc_type` | Type de document demandé par le consommateur (e.g. `financial`) | 1-32 caractères, regex `[a-z0-9_.-]+` |
| `content_type` | MIME type du fichier généré (ex: `application/pdf`) | non vide, pas d'espaces ni de tabulations/retours | 
| `message_id` | Identifiant unique du message | non vide, pas d'espaces/ tabs/retours, 1-64 caractères |
| `payload` | Dossier contenant les fichiers JSON additionnels (ex: `sample_student.json`) | Doit pointer sur un dossier existant et lisible |

> Les requêtes `publish_test_message --json` et `test_publish_test_message` exécutent ces validations et renvoient `status=error` si l'un des champs ne respecte pas les règles (longueur, regex, contenu blanc, payload manquant ou illisible).

## Réponses

- En cas de succès, le service retourne JSON :
```json
{
  "status": "ok",
  "routing_key": "...",
  "pdf_output_dir": "/tmp/mq-pdfs",
  "pdf_output_dir_missing": 0
}
```
- En cas d'erreur JSON ou champ invalide, `status=error` et un message explicite précisent la raison (`content_type blank`, `message_id whitespace`, `payload not found`, etc.). Les tests `test_matrix`/`tests_summary` attendent ces codes d'erreur pour les scénarios invalides.

## Génération de PDF

- La génération de PDF est confiée aux consumers (shared/pdfs). L'API ne renvoie pas le PDF directement.
- La variable d'environnement `PDF_OUTPUT_DIR` (par défaut `shared/pdfs/`) peut être surchargée pour rediriger les fichiers durant les runs locaux (`./scripts/test_e2e_local.sh --json`). En dry-run, `e2e_local` crée `PDF_OUTPUT_DIR` si absent et renseigne `pdf_output_dir_missing`.
- Les helpers `scripts/post_sample.sh`, `scripts/publish_test_message.sh` et les docs `local_runbook`, `troubleshooting_env`, `quickstart` recommandent de précréer ce dossier et de nettoyer les PDF avant les démonstrations (`tests_summary` note `PDF_OUTPUT_DIR` cleanup, `logging` liste le chemin, `security_notes` rappelle les permissions). Quand le dossier est writable, les consumers stockent les artefacts consultables.

## Tests et validation

- `test_publish_test_message` vérifie les champs et produit des erreurs pour les cas de JSON invalide (payload absent, `content_type` vide/blanc, `message_id` blanc/whitespace/newline). Il sert aussi à démontrer la sortie `status=error` via `--json`.
- `test_matrix`, `test_tools`, `tests_consumers`, `tests_producer`, `tests_summary` vérifient la sensibilité à `PDF_OUTPUT_DIR` (nettoyage des fichiers).
- `test_e2e_local`/`scripts/test_e2e_local.sh --json` utilisent `PDF_OUTPUT_DIR` pour générer un dry-run JSON précisant `pdf_output_dir`/`pdf_output_dir_missing`. Les logs `module_status`, `module_layout`, `run_modules`, `smoke_plan`, `todo_next` précisent cet artefact afin que la revue puisse confirmer la structure des dossiers.

## Vérifications supplémentaires

- Utiliser `jq '.pdf_output_dir,.pdf_output_dir_missing'` après un dry-run pour valider le chemin et la valeur `pdf_output_dir_missing` (indicée par `tests_summary`).
- La documentation `docs_index`/`module_status`/`smoke_plan` rappelle d’exécuter `scripts/test_e2e_local.sh --json` avec `PDF_OUTPUT_DIR` préconfiguré, puis de nettoyer les PDF et de vérifier les exports CSV/JSON (`reports/...status_top2.*`) via `tail -n 5 ...` comme indiqué dans `test_tools` et `logs_metrics`.
- Le script `scripts/check_publish_payload.py` peut être utilisé pour valider manuellement un JSON avant de lancer `publish_test_message`. L’option `--json` la rend intégrable aux suites (`test_publish_test_message`, `test_matrix`) afin que les messages d’erreur soient alignés avec ceux documentés ici (longueur, regex, payload readable, absence d’espaces, etc.).
- Le fichier `docs/sample_publish_payload.json` illustre un payload valide (exchange/routing/doc_type/content_type/message_id/payload). Il sert de référence pour `check_publish_payload.py` et les démonstrations manuelles : il suffit d’exécuter `./scripts/check_publish_payload.py --payload docs/sample_publish_payload.json --directory docs --json` puis d’utiliser ce JSON avec `publish_test_message` pour confirmer que la validation passe en conditions réelles.

## Notes de revue

Indiquer dans les notes des relecteurs comment reproduire la validation (commande de test, `tail -n 5 ...`, capture `status=error`/`json_error`, mention `PDF_OUTPUT_DIR`). Les `progress`/docs `troubleshooting_env`, `quickstart`, `local_usage`, `local_runbook`, `http_endpoints` et `api_contract` doivent mentionner clairement les contraintes pour éviter de rejeter la PR.
