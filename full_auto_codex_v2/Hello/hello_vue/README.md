# hello_vue

## Synthèse
Réécriture locale des exercices d’initiation Vue.js (v2) du sujet *hello_vue*. Chaque exercice fournit un `index.html` autonome conforme aux consignes, prêt à être ouvert dans un navigateur sans dépendances supplémentaires.

## Architecture & approche
- `ex00` : affichage simple de « Hello 42! » avec le titre requis.
- `ex01` : rendu conditionnel via `v-if` et propriété `seen`.
- `ex02` : boutons `SHOW`/`HIDE` qui manipulent `seen` par des gestionnaires `@click`.
- `ex03` : liaison bi-directionnelle `v-model` sur un champ de saisie.
- `ex04` : composant global `hello` réutilisé dans la vue principale.
- `ex05` : composant `series-item` recevant ses données par props et itéré avec `v-for`.
- `tests_realisation/` : scripts de validation automatique et documentation des commandes.
- `Sujet_hello_vue.pdf` : lien symbolique vers le sujet officiel.

Tous les fichiers HTML chargent Vue 2.6.14 depuis le CDN officiel (`https://unpkg.com`) afin de respecter la contrainte de version minimale.

## Exécution
Chaque exercice est autonome. Depuis la racine du projet, pour servir l’ensemble des fichiers avec un serveur simple :

```bash
python3 -m http.server 8080
```

Puis ouvrir dans le navigateur l’URL `http://localhost:8080/ex0X/` correspondante et sélectionner `index.html`. À défaut, un double-clic sur chaque fichier `index.html` fonctionne également.

## Tests
- `./tests_realisation/run_tests.sh` : lance les vérifications statiques qui inspectent les fichiers HTML et s’assurent que chaque contrainte du sujet est présente.

## Répartition des PDF
- `Sujet_hello_vue.pdf` : sujet principal unique couvrant les six exercices requis.
