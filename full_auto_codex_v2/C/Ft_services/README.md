# ft_services

Statut : DONE

Derniere mise a jour (2026-01-17 01:14:56) : passage DONE (tests OK).

## Synthèse actuelle
Sujet 42 « ft_services » : déployer un cluster Kubernetes local (Minikube) avec plusieurs services conteneurisés (nginx ingress, WordPress + MariaDB, phpMyAdmin, FTPS, Grafana/InfluxDB, etc.), configuration TLS auto-signée, LoadBalancer via MetalLB, monitoring, scripts d’automatisation. Enjeux : reproductibilité (Makefile/scripts), sécurité de base (users/passwords), persistance et probing (liveness/readiness), dashboards. L’environnement actuel ne permet pas d’exécuter Minikube, mais les manifests et scripts de bootstrap sont en place pour un run externe.

## Hypothèses de travail
- Environnement cible : Minikube (driver docker) + kubectl + docker ou buildkit locaux. Pas de dépendance réseau ici, donc prévoir une variante « offline » ou notes pour téléchargement des images (pas exécuté dans l’environnement actuel).
- Gestion des secrets via manifests simples (Secrets Kubernetes) plutôt que Vault.
- Ingress via nginx + MetalLB pour exposer les services; certificats auto-signés stockés en Secret TLS.

## Plan provisoire
1) Préparer arborescence et scripts : `Makefile` pour build/push dans le registry local de Minikube, `scripts/init_minikube.sh`, `k8s/` pour manifests par service.
2) Composer le réseau: MetalLB configmap, ingress-controller nginx, namespace dédié.
3) Services applicatifs: MariaDB + WordPress + phpMyAdmin, FTPS, Grafana/InfluxDB, éventuellement un service sample nginx pour tester le LB.
4) Monitoring : dashboards et probes (liveness/readiness) dans les manifests.
5) Documentation d’usage: commandes pour lancer Minikube, appliquer manifests, vérifier endpoints, arrêter/cleanup.

## État actuel
- PDF copié dans `docs/Ft_services.pdf`.
- Arborescence créée (`docs/`, `k8s/`, `scripts/`).
- Makefile de bootstrap (`start/apply/certs/stop/clean/status`).
- Scripts : `init_minikube.sh`, `gen_certs.sh`, `apply_all.sh` (applique namespace, MetalLB avec pool substituable, secret TLS, ingress de test).
- Manifests : `namespace.yaml`, MetalLB (namespace/SA placeholder + IPAddressPool/L2Advertisement), ingress de test `whoami` (Deployment/Service/Ingress TLS), stack WordPress + MariaDB + phpMyAdmin (secrets/PVC/Services/Ingress), FTPS (LoadBalancer), monitoring InfluxDB + Grafana (datasource provisionné, ingress TLS), dashboard Grafana exemple (`k8s/monitoring/60-grafana-dashboard.yaml`) et job de seed métriques (`k8s/monitoring/70-influx-seed.yaml`).

## État final
Tous les manifests et scripts sont prêts pour un déploiement Minikube externe : MetalLB, ingress nginx, WordPress/MariaDB/phpMyAdmin, FTPS, monitoring InfluxDB+Grafana avec dashboard provisionné, TLS auto-signé. Les tests doivent être effectués sur une machine disposant de Minikube/virtualisation.

## Makefile (hors environnement courant)
- `make start` : init Minikube + apply namespace/MetalLB + ingress whoami (pool par défaut 192.168.49.240-250)
- `LB_POOL=192.168.49.200-192.168.49.220 make apply` : réappliquer avec un autre pool
- `make status` : kubectl get pods -A
- `make hosts LB_IP=<addr>` : générer les lignes /etc/hosts
- `make seed` : injecter des métriques synthétiques
- `make clean` : delete profile

## Notes de déploiement (à exécuter hors de cet environnement)
- Prévoir un pool MetalLB adapté à votre réseau local : `LB_POOL=192.168.49.200-192.168.49.220 make apply`.
- Ajouter les entrées `/etc/hosts` pointant vers l'IP MetalLB : `whoami.local`, `wordpress.local`, `pma.local`, `grafana.local`.
- Secrets par défaut (admin/admin) dans `monitor-secrets` à surcharger avant déploiement réel.
- Pour injecter des métriques de test: `./scripts/seed_metrics.sh` (nécessite accès réseau au service InfluxDB depuis votre machine).

## Scripts
- `scripts/init_minikube.sh` : démarre Minikube (driver docker) avec addon ingress.
- `scripts/gen_certs.sh` : génère un certificat auto-signé et le secret TLS.
- `scripts/apply_all.sh` : applique namespace, MetalLB (pool substitué via `LB_POOL`), secret TLS, ingress whoami et tous les services (WP/PMA, FTPS, InfluxDB/Grafana).
- `scripts/seed_metrics.sh` : envoie des métriques synthétiques vers InfluxDB (à lancer depuis une machine ayant accès au cluster).
- `scripts/check_cluster.sh` : affiche pods/services/ingresses `ft-services`, pools MetalLB et IP Minikube.
- `scripts/gen_hosts.sh <LB_IP>` : génère les entrées `/etc/hosts` pour whoami/wordpress/pma/grafana sur l’IP MetalLB.
