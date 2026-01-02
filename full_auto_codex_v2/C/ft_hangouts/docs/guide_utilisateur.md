# Guide utilisateur (CLI)

Ce guide couvre le prototype CLI de `ft_hangouts`. Il simule les actions principales (contacts, messages, notifications) et sert de base pour la future version Android.

## 1) Démarrer

```bash
python3 src/mock_app.py --lang fr
```

> Le store est enregistré dans `data/store.json`.

## 2) Contacts

Créer un contact (avatar optionnel) :
```bash
python3 src/mock_app.py contacts add \
  --first-name Alice --last-name V --phone 0600000001 \
  --email alice@42.fr --campus Paris --tags dev staff --avatar alice.png
```

Lister et filtrer :
```bash
python3 src/mock_app.py contacts list
python3 src/mock_app.py contacts list --tag dev
python3 src/mock_app.py contacts list --campus Paris
```

Mettre a jour ou supprimer :
```bash
python3 src/mock_app.py contacts edit --contact-id 1 --phone 0600000009
python3 src/mock_app.py contacts delete --contact-id 1
```

Avatar :
```bash
python3 src/mock_app.py contacts set-avatar --contact-id 2 --avatar bob.jpg
```

## 3) Messages

Envoyer et recevoir :
```bash
python3 src/mock_app.py messages send --contact-id 1 --body "Hello"
python3 src/mock_app.py messages receive --contact-id 1 --body "Hi"
```

Reception d'un numero inconnu (auto-creation) :
```bash
python3 src/mock_app.py messages receive --phone 0600000003 \
  --first-name Chloe --last-name Z --avatar chloe.png --auto-create \
  --body "Salut"
```

Lister, filtrer, marquer comme lus :
```bash
python3 src/mock_app.py messages list --contact-id 1
python3 src/mock_app.py messages list --contact-id 1 --unread-only
python3 src/mock_app.py messages mark-read --contact-id 1
```

Recherche :
```bash
python3 src/mock_app.py messages search --query ping
python3 src/mock_app.py messages search --query ping --contact-id 2
```

## 4) Notifications

```bash
python3 src/mock_app.py notifications
python3 src/mock_app.py notifications --json
python3 src/mock_app.py notifications --as-background
```

## 5) Conversations

```bash
python3 src/mock_app.py conversations
python3 src/mock_app.py conversations --json
```

## 6) Parametres (theme CLI)

```bash
python3 src/mock_app.py settings show
python3 src/mock_app.py settings set-theme --color green
```

## 7) Import / export

Messages :
```bash
python3 src/mock_app.py messages export --contact-id 2 --output out.json
python3 src/mock_app.py storage export --output backup.json
python3 src/mock_app.py storage import --input backup.json
```

Contacts CSV :
```bash
python3 src/mock_app.py contacts export --output contacts.csv
python3 src/mock_app.py contacts import --input contacts.csv
```

## 8) Appels (bonus)

```bash
python3 src/mock_app.py calls log --contact-id 1 --direction OUT --duration 120
python3 src/mock_app.py calls log --contact-id 2 --direction IN --missed
python3 src/mock_app.py calls list
python3 src/mock_app.py calls list --missed-only
python3 src/mock_app.py calls stats --json
python3 src/mock_app.py calls export --output calls.json
python3 src/mock_app.py calls import --input calls.json
```

## 9) Scenario automatise

```bash
./tests_realisation/run_tests.sh
```

Le script reinitialise le store, cree des contacts, simule des messages et verifie les exports.
