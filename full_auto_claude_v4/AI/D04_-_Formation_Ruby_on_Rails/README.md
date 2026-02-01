# D04 - Formation Ruby on Rails

Ce projet contient 4 exercices de formation Ruby on Rails.

## Structure du projet

```
D04_-_Formation_Ruby_on_Rails/
├── ex00/CheatSheet/       # Exercice 00 - Page unique CheatSheet
├── ex01/NewCheatSheet/    # Exercice 01 - Multi-pages avec navbar
├── ex02/CheatSheet/       # Exercice 02 - Quick search avec DataTables
├── ex03/CheatSheet/       # Exercice 03 - Log Book avec formulaire
├── Dockerfile             # Configuration Docker
├── docker-compose.yml     # Docker Compose
└── README.md
```

## Exercice 00 - CheatSheet

Application Rails simple avec une page unique affichant une cheatsheet Ruby on Rails.

**Caractéristiques:**
- Application nommée "CheatSheet"
- Un seul contrôleur personnalisé (`cheatsheet_controller.rb`)
- Page principale avec title "CheatSheet"
- Pas de navbar
- Mise en page avec Bootstrap

## Exercice 01 - Moar CheatSheet

Application Rails multi-pages avec navigation.

**Caractéristiques:**
- Application nommée "NewCheatSheet"
- Navbar partagée (partial `_navbar.html.erb`)
- 13 pages distinctes:
  - convention (root)
  - console
  - ruby
  - ruby-concepts
  - ruby-numbers
  - ruby-strings
  - ruby-arrays
  - ruby-hashes
  - rails-folder-structure
  - rails-commands
  - rails-erb
  - editor
  - help
- Chaque page a sa propre balise title

## Exercice 02 - Quick Search

Extension de l'exercice 01 avec recherche.

**Caractéristiques:**
- Nouvel onglet "Quick Search"
- Tableau récapitulatif de toutes les commandes
- Intégration jQuery DataTables pour:
  - Recherche dynamique
  - Pagination
  - Tri des colonnes

## Exercice 03 - Diary

Extension de l'exercice 02 avec journal technique.

**Caractéristiques:**
- Nouvel onglet "Log Book"
- Formulaire pour ajouter des entrées
- Stockage dans `entry_log.txt` à la racine
- Format: `DD/MM/YYYY HH:MM:SS : texte`
- Affichage des entrées du plus récent au plus ancien

## Prérequis

- Docker
- Ruby 3.2.x
- Rails 7.1.x

## Installation et exécution

### Avec Docker

```bash
# Construire l'image
docker build -t rails-cheatsheet .

# Lancer une application (exemple: ex00)
cd ex00/CheatSheet
docker run --rm -v $(pwd):/app -w /app -p 3000:3000 ruby:3.2 bash -c "
  gem install bundler
  bundle install
  rails server -b 0.0.0.0
"
```

### Sans Docker (Ruby installé localement)

```bash
cd ex00/CheatSheet
bundle install
rails server
```

Accéder à l'application: http://localhost:3000

## Gems utilisées

- `bootstrap` - Framework CSS
- `rubycritic` - Analyse de qualité du code
- `jquery-datatables-rails` - Tableaux interactifs (ex02, ex03)
- `jquery-rails` - jQuery pour Rails

## Tests

Pour vérifier la qualité du code:

```bash
cd exXX/AppName
bundle exec rubycritic
```

Le rapport sera généré dans `tmp/rubycritic/`.

## Notes

- Rails 7.1.5 utilisé (version moderne, concepts identiques à Rails 4.2.7)
- Bootstrap 5.3 via CDN pour simplicité
- DataTables via CDN pour ex02 et ex03
- Pas d'utilisation des mots-clés interdits (while, for, redo, break, retry, loop, until)

## Auteur

Projet réalisé dans le cadre de la formation 42.
