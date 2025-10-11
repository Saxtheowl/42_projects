# hello_node

## Compréhension du sujet
Le sujet *hello_node* est une initiation progressive à Node.js. Il enchaîne dix petits exercices (ex00 à ex09) pour manipuler la sortie standard, les arguments, la lecture de fichiers synchrone/asynchrone, les requêtes HTTP, la gestion d'un serveur TCP ainsi qu'un serveur HTTP JSON.

## Réalisation
Chaque exercice est codé dans `src/exXX/` conformément aux consignes du PDF :
- **ex00** affiche `HELLO WORLD` sur la sortie standard.
- **ex01** met en scène différents types JavaScript et leur affichage.
- **ex02** additionne les arguments numériques en ligne de commande en signalant toute valeur invalide.
- **ex03** compte les retours à la ligne via `fs.readFileSync`.
- **ex04** réalise le même comptage en mode asynchrone avec `fs.readFile`.
- **ex05** consomme un flux HTTP(S) et affiche chaque bloc reçu.
- **ex06** collecte l'intégralité du flux avant de publier sa taille et son contenu.
- **ex07** orchestre trois téléchargements HTTP(S) et restitue les réponses dans l'ordre d'entrée.
- **ex08** expose un serveur TCP qui renvoie la date/heure courante formatée.
- **ex09** répond à deux routes HTTP en JSON (`/api/parsetime` et `/api/unixtime`).

Aucun module externe n'est nécessaire. Les scripts tolèrent les erreurs d'entrée (arguments manquants, protocoles non supportés, etc.) sans planter brutalement.

## Compilation / Exécution
Node.js ≥ 14 suffit. Depuis `full_auto_codex/hello_node/` :

```bash
node src/ex00/hello-world.js
node src/ex02/sum_args.js 1 2 3
node src/ex03/io.js path/to/file
node src/ex08/time-server.js 8080
node src/ex09/http-json-api-server.js 8080
```

Les autres exercices suivent la même logique (`src/exXX/<script>.js`).

## Tests
Un banc d'essai commun est disponible dans `../tests_realisation/` :

```bash
python3 ../tests_realisation/hello_node_tests.py
```

Ce script démarre des serveurs HTTP/TCP temporaires pour valider automatiquement les comportements attendus et affiche l'état de chaque exercice.
