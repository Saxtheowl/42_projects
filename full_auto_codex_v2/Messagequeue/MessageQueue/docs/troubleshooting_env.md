# Troubleshooting env

## .env non charge
Symptome : scripts utilisent toujours guest/localhost.

Actions :
1) Verifier le fichier .env :
```bash
ls -l .env
```
2) Charger l'env :
```bash
./scripts/load_env.sh
```

## Erreur auth API management
Symptome : check_rabbitmq.sh echoue.

Actions :
1) Verifier RABBITMQ_USER/RABBITMQ_PASS dans .env.
2) Tester :
```bash
./scripts/check_rabbitmq.sh
```

## VHOST incorrect
Symptome : queues introuvables.

Actions :
1) RABBITMQ_VHOST par defaut est `/`.
2) Mettre a jour .env puis relancer :
```bash
./scripts/load_env.sh
./scripts/validate_rabbitmq.sh
```

## Docker non disponible
Symptome : check_prereqs signale docker manquant.

Actions :
1) Installer docker et docker compose.
2) Relancer :
```bash
./scripts/check_prereqs.sh
```

## Maven manquant
Symptome : `mvn` introuvable lors des builds/tests.

Actions :
1) Installer Maven (ex: paquet `maven`).
2) Relancer :
```bash
./scripts/check_prereqs.sh
```

## Doctor JSON incomplet
Symptome : un script externe attend un champ manquant dans la sortie de doctor.

Actions :
1) Utiliser le mode JSON :
```bash
./scripts/doctor.sh --json
```
2) Verifier que les champs `payload_tests` et `publish_tests` sont presents.

## publish_test_message refuse les parametres
Symptome : erreurs du type `EXCHANGE must be...`, `ROUTING_KEY must be...` ou `CONTENT_TYPE must be...`.

Actions :
1) Verifier les formats : lettres/chiffres/point/underscore/hyphen pour EXCHANGE/ROUTING_KEY.
2) Verifier les longueurs (<=255) et que CONTENT_TYPE n'est pas uniquement des espaces/tabs/newlines; MESSAGE_ID ne doit pas contenir d'espaces/tabs/newlines (whitespace) (les valeurs vides prennent le default).
3) Tester en dry-run pour isoler le probleme :
```bash
./scripts/publish_test_message.sh --dry-run
```

## publish_test_message JSON invalide
Symptome : message `Payload file is not valid JSON`.

Actions :
1) Verifier que le fichier est un JSON valide (accolades, virgules, guillemets).
2) Tester la validation locale :
```bash
./scripts/validate_payload.py --json
```

## publish_test_message payload introuvable/dossier
Symptome : message `Payload file not found` ou `Payload file is a directory`.

Actions :
1) Verifier `PAYLOAD_FILE` et la presence du fichier.
2) Si vous pointez un dossier, indiquer un fichier JSON.

## publish_test_message --json sans python3
Symptome : erreurs affichees en stderr au lieu d'une sortie JSON.

Actions :
1) Installer `python3`.
2) Relancer la commande en `--json`.

## publish_test_message ne peut pas écrire les PDF
Symptome : erreur `Permission denied` ou `PDF_OUTPUT_DIR` manquant dans la sortie JSON.

Actions :
1) Vérifier que `PDF_OUTPUT_DIR` est défini et pointe vers un dossier que vous contrôlez.
2) Lancer `./scripts/verify_pdf_output_dir.sh` pour créer/rendre accessible ce dossier et détecter les permissions fautives.
3) Ré-exécuter `publish_test_message` une fois la vérification passée.
