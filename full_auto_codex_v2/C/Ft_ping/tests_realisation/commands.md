# Tests ft_ping

## Scripts automatisés
- `scripts/run_tests.sh` — reconstruit le binaire puis exécute une batterie de fumée sans privilèges (vérification du message d'usage et du contrôle des droits root).

## Vérifications manuelles (requièrent l'utilisateur root)
1. `sudo ./ft_ping 127.0.0.1` — vérifie un aller-retour ICMP classique et les statistiques finales.
2. `sudo ./ft_ping -v 8.8.8.8` — inspecte l'affichage verbeux en cas de réponses ICMP non standards.
3. `sudo ./ft_ping host.domaine` — contrôle de la résolution FQDN et du banner `PING`.

> Les tests nécessitant des privilèges sont documentés mais non automatisés par défaut pour conserver un fonctionnement sans élévation dans le CI.
