# Maquettes textualisées

> Basse fidélité (texte + ASCII) pour guider la réalisation rapide sous Android. Les couleurs/thèmes sont indiquées mais restent indicatives.

## 1. Écran d'accueil — Liste des hangouts & contacts récents

```
----------------------------------------------------------
| Header (color=Primary)         [Menu] [Search]          |
|--------------------------------------------------------|
| Hangouts                                                         |
|  - #Piscine Rush02        128 membres   Dernier msg 3m |
|  - #Hackathon             54 membres    Dernier msg 1h |
|--------------------------------------------------------|
| Contacts récents                                             >  |
|  [AV] Alice V.     Mentore   Dernier SMS : "Merci !"         |
|  [CL] Clara L.     Staff     Dernier SMS : "News event..."   |
|--------------------------------------------------------------|
| FAB (+) -> New Contact / New Hangout                         |
---------------------------------------------------------------
  Toast (return from background) : "Repris : 2025-10-27 14:32"
```

## 2. Fiche contact (tabs)

```
----------------------------------------------------------
| <- | Alice VS (Mentor)             [Palette icon]       |
|--------------------------------------------------------|
| Tabs:  [Infos] [Messages]                               |
|--------------------------------------------------------|
| [Infos]                                                 |
|  Téléphone : +33 6 12 34 56 78                          |
|  Email     : alice@42.fr                                |
|  Campus    : 42 Paris                                   |
|  Tags      : #Piscine  #Mentor                          |
|  Notes     : Préfère DM matin                           |
|  Actions   : [Editer] [Supprimer]                       |
|--------------------------------------------------------|
| [Messages]                                               |
|  10:00 OUT  Salut, dispo pour Rush02 ?                  |
|  10:05 IN   Oui, rdv cluster B                          |
|  ------------------------------------------------------ |
|  Champ saisie + bouton Envoyer                          |
----------------------------------------------------------
```

## 3. Création contact

```
----------------------------------------------------------
| Header : Nouveau contact (Langue = FR/EN)               |
|--------------------------------------------------------|
| Form                                                      |
|  Nom*         [______________]                           |
|  Prénom*      [______________]                           |
|  Téléphone*   [______________]                           |
|  Email        [______________]                           |
|  Campus       [Select  v]                                |
|  Tags         [Chips / MultiSelect]                      |
|  Notes        [Multiline]                                |
|  Toggle photo (bonus)                                    |
|--------------------------------------------------------|
| [Annuler]                         [Enregistrer]         |
----------------------------------------------------------
```

## 4. Paramètres (drawer / settings fragment)

```
----------------------------------------------------------
| Header : Paramètres                                     |
|--------------------------------------------------------|
| Langue                                                  |
|    ( ) Français   ( ) English                           |
| Thème                                                   |
|    [ Bleu ] [ Violet ] [ Vert ]                         |
| Notifications                                           |
|    [x] Alertes push Hangouts officiels                  |
|    [ ] Création auto contact numéro inconnu            |
| Historique                                              |
|    Dernière mise en arrière-plan : 27/10 14:32          |
----------------------------------------------------------
```

## 5. Conversation paysage

```
-------------------------------------------
| Contacts        | Conversation          |
| Alice V. (Ment) | 14:00 OUT Salut !     |
| Ben T. (Mentor) | 14:01 IN  Coucou :)   |
| Clara (Staff)   | --------------------- |
| ...             | Champ saisie [Send]   |
-------------------------------------------
```

Ces maquettes servent de guide ; la version finale pourra adopter Material 3 (bonus). Chaque écran doit respecter le cahier des charges : persistance, multi-langue, changement de couleurs, notifications.
