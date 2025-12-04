# Django Training D01

## Synthèse
Kickoff du cursus Python/Django (jour 01) : prise en main de Django, création d'un projet basique et de quelques vues simples. Ce dépôt sert à cadrer les exercices D01 avec un environnement reproductible (venv/requirements), un projet Django racine et des apps à compléter selon le PDF.

## Plan
- Lire le PDF (`docs/D01_-_Python-Django_training.pdf`) et lister les exos/deliverables attendus.
- Initialiser venv + requirements (Django).
- Générer le projet Django (`django-admin startproject training_d01`).
- Créer les apps demandées (par ex. `ex00`, `ex01`, etc.) et remplir les vues/templates selon le sujet.
- Ajouter scripts de run/tests (`manage.py test`, lint basique).
- Documenter dans ce README comment lancer le serveur et les tests.

## Environnement prévu
- Python 3.x
- Django (version à fixer selon le sujet, par défaut 4.x)
- venv local : `python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt`

## Avancement
- Projet Django `training_d01` initialisé (settings/urls/wsgi/asgi, manage.py).
- Requirements posés (`Django>=4.2,<5.0`).
- Reste à lire le PDF et implémenter les exercices/applications demandées.

## Lancement (développement)
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```
