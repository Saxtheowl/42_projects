# Exemples de routing keys

## Social assistance
Fanout: toutes les queues recoivent chaque message (cle ignoree).

## Grants (topic)
- `grant.application` -> `grant_other_documents`
- `grant.guarantee` -> `grant_other_documents`
- `grant.1.contract` -> `grant_contracts` + `grant_other_documents`
- `grant.2.contract` -> `grant_other_documents`

## Conseils
- Prefixer par `grant.` pour tous les documents de bourse.
- Utiliser `grant.1.*` pour les contrats du niveau 1.
