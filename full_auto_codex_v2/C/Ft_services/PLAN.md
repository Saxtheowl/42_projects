# Plan ft_services

## Objectif
Déployer un ensemble de services sur Minikube : MetalLB (LoadBalancer), nginx ingress, WordPress + MariaDB, phpMyAdmin, FTPS, Grafana/InfluxDB, avec monitoring et certificats auto-signés. Automatisation via Makefile/scripts.

## Étapes prévues
1) **Bootstrap Minikube** : script `scripts/init_minikube.sh` (driver docker, cpus/memory configurables), activation addons ingress/dashboard/metrics-server si disponibles.
2) **Réseau & TLS** :
   - Manifeste MetalLB (`k8s/metallb/`) avec pool d’adresses substituable via `LB_POOL`.
   - Certificats auto-signés via script `scripts/gen_certs.sh` (ingress TLS) stockés en Secret.
3) **Services de base** :
   - Namespace `ft-services`.
   - Ingress controller nginx (si non fourni par addon) + ingress de test `whoami` (Deployment/Service/Ingress TLS).
4) **Applications** :
   - MariaDB StatefulSet + PVC, WordPress Deployment + Service, phpMyAdmin Deployment.
   - FTPS (pod dédié) avec volume pour certs/users.
   - Grafana + InfluxDB (ou Prometheus) pour monitoring.
5) **Probing & monitoring** :
   - Liveness/readiness sur pods, dashboards basiques.
6) **Automatisation** :
   - Makefile cibles : `make start`, `make stop`, `make clean`, `make status`, `make apply`.
   - Scripts helper pour builder les images et injecter dans le registry Minikube (ou `minikube image load`).

## Blocages / prérequis
- Accès à Minikube/virtualisation et images conteneurs non garantis dans l’environnement actuel (sandbox sans réseau). Prévoir instructions mais ne pas exécuter ici.

## Prochaines actions
- Ajouter un dashboard Grafana provisionné (ConfigMap) et une source de métriques (exporters ou app demo). ✅ dashboard exemple + job de seed Influx + script de seed.
- Préparer un ingress global avec hôtes et routes pour chaque service, réutilisant le secret TLS.
