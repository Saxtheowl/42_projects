# hello_node

Statut : WAITING (tests reseau bloques sans sockets locales)

Derniere mise a jour (2026-01-26 11:02:32) : ajout run_tests_auto.sh (auto-skip reseau), tests OK avec sockets bloquees.

## Synthèse
Portage local des dix exercices d'initiation Node.js du sujet *hello_node*. Chaque sous-dossier `ex0X/` contient un script autonome ciblant l'API standard (`fs`, `http`, `net`), sans dépendances externes, conforme aux attentes de correction pair-à-pair.

## Architecture & approche
- `ex00/hello-world.js` : affichage direct de `HELLO WORLD`.
- `ex01/vars.js` : exploration des types JavaScript via `typeof`.
- `ex02/sum_args.js` : agrégation arithmétique des arguments CLI.
- `ex03/io.js` : lecture synchrone du fichier (nombre de retours à la ligne).
- `ex04/asyncio.js` : équivalent asynchrone avec `fs.readFile`.
- `ex05/http-client.js` : client HTTP streaming (`http.get`) affichant chaque chunk.
- `ex06/http-collect.js` : collecte complète, longueur puis contenu.
- `ex07/async-http-collect.js` : collecte de multiples URLs en conservant l'ordre.
- `ex08/time-server.js` : serveur TCP formatant la date `YYYY-MM-DD hh:mm`.
- `ex09/http-json-api-server.js` : API HTTP JSON (`/api/parsetime`, `/api/unixtime`).
- `tests_realisation/` : scripts de validation automatisés et fixtures locales.
- `Sujet_hello_node.pdf` : lien symbolique vers le sujet officiel.

Les scénarios réseau sont couverts par des serveurs locaux factices dans les tests, évitant toute dépendance externe.

## Exécution
Chaque exercice se lance depuis la racine du projet, par exemple :

```bash
node ex05/http-client.js "http://example.org"
node ex08/time-server.js 8080
```

Pour servir les fichiers et tester rapidement, il est possible d'utiliser `node` directement sans configuration supplémentaire (Node ≥ 14 requis par le sujet, la réalisation a été validée avec Node 22).

## Tests
- `./tests_realisation/run_tests.sh` : exécute toutes les vérifications (I/O, HTTP, TCP) via Node.js.
- `HELLO_NODE_SKIP_NET=1 ./tests_realisation/run_tests.sh` : saute les tests réseau si l'environnement bloque les sockets locales.
- `./tests_realisation/run_tests_skip_net.sh` : raccourci pour exécuter la suite en mode sans réseau.
- `./tests_realisation/run_tests_auto.sh` : tente les tests réseau, sinon bascule automatiquement en mode sans réseau.

## Répartition des PDF
- `Sujet_hello_node.pdf` : unique support décrivant les exercices 00 à 09.
