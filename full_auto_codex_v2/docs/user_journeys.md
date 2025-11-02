# User Journeys

## 1. Découverte & Onboarding (Alice)
1. Alice télécharge l’app et s’authentifie via l’Intra 42.
2. L’app affiche un walkthrough rapide (3 écrans) présentant les fonctionnalités.
3. Elle arrive sur la page d’accueil : liste de hangouts populaires + recherche.
4. Alice rejoint le hangout "Piscine Rush02" et active les notifications.
5. Elle ajoute un contact mentor, peut lui envoyer un premier message.

## 2. Création de hangout (Ben)
1. Ben ouvre son menu principal > "Créer un hangout".
2. Il saisit : nom, description, visibilité (privé/public), tags, image.
3. Il invite ses mentees en sélectionnant des contacts existants.
4. Ben publie l’agenda et programme un rappel (notification push).

## 3. Diffusion d’annonce (Clara)
1. Clara dispose d’un rôle staff donnant accès à la console modération.
2. Elle sélectionne un hangout officiel et poste un message important.
3. Elle bascule la langue par défaut (français/anglais) pour la publication.
4. Un toast informant de la dernière ouverture apparaît (time-in-background requirement).

## 4. Gestion contact & SMS
1. Depuis la fiche contact, l’utilisateur peut :
   - éditer nom, rôle, campus, téléphone, tags, notes,
   - consulter l’historique des SMS (stockés en local),
   - envoyer un nouveau SMS (via API/Mock),
   - recevoir SMS (service background + notification + insertion auto si option activée).
2. Changements de header/Thème via menu : sauvegardé en SharedPreferences.

## 5. Retour foreground
1. L’utilisateur met l’app en arrière-plan.
2. À la reprise, un toast affiche la date/heure de mise en arrière-plan.
3. La liste des hangouts se rafraîchit (pull-to-refresh) pour montrer les nouveaux messages.
