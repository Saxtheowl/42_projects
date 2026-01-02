# Parcours utilisateur (CLI)

## 1) Onboarding contact
- L'utilisateur lance le CLI et ajoute un premier contact avec les champs obligatoires.
- Le contact apparait immediatement dans la liste avec tags, campus et avatar.
- L'utilisateur exporte les contacts en CSV pour conserver un snapshot.

## 2) Reception SMS inconnu
- Un message entrant arrive d'un numero inconnu.
- Le CLI cree automatiquement le contact (nom/numero/avatars fournis) et stocke le message IN.
- L'utilisateur consulte les notifications non lues, puis marque la conversation comme lue.

## 3) Gestion conversations
- L'utilisateur consulte le resume des conversations.
- Les contacts epingles remontent en tete, les mutés n'apparaissent pas dans les notifications.
- La recherche par mot cle permet de retrouver rapidement un message.

## 4) Sauvegarde et restauration
- L'utilisateur exporte le store complet en JSON.
- Une restauration repopule le store et permet de reprendre l'historique.
