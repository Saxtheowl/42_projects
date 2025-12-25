# Monitoring (Grafana + InfluxDB)

- Secrets : `00-monitor-secrets.yaml` (admin/admin par défaut, à personnaliser).
- InfluxDB : `40-influxdb.yaml` (PVC 1Gi, auth activée, DB ft_services).
- Grafana : `50-grafana.yaml` (datasource provisionnée vers InfluxDB, ingress TLS grafana.local).
- Dashboard exemple : `60-grafana-dashboard.yaml` (ConfigMap provisionnée via label grafana_dashboard=1).

Exporter/metrics : non branché ici (environnement sans workload réel). Vous pouvez injecter des mesures synthétiques dans InfluxDB pour valider le dashboard (ex: `INSERT ingress_requests value=42`).
