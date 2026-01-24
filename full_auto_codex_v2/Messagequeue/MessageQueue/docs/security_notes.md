# Security notes

- Ne pas commit de credentials dans le repo.
- Utiliser `.env` pour surcharger `RABBITMQ_USER`/`RABBITMQ_PASS`.
- Eviter d'exposer le port 15672 en public.
- Restreindre les acces aux dossiers `shared/` (payloads/PDFs) en local.
- Supprimer les PDFs de test contenant des donnees sensibles apres usage.
