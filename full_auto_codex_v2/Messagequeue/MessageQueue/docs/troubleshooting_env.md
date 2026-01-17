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
