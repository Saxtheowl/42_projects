# ACK policy (consumers)

Recommandations :
- Ack apres generation PDF reussie.
- Nack (requeue=true) en cas d'erreur transitoire.
- Nack (requeue=false) pour erreurs de payload non recuperables.

Exemple :
- JSON invalide -> Nack sans requeue.
- Ecriture PDF fail (disk full) -> Nack avec requeue.
